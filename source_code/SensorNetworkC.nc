/**
 *  @author Christian Zichichi
 */


#include "Timer.h"
#include "SensorNetwork.h"
#include "SensorNetworkSerial.h"
//#include "printf.h"

module SensorNetworkC @safe(){

  uses {
	interface Boot;
	interface AMPacket;
	
 	interface Packet as RadioPacket;
	interface Packet as SerialPacket;
	interface PacketAcknowledgements;
	
  	interface AMSend as RadioAMSend;
	interface AMSend as SerialAMSend;
	
	interface SplitControl as RadioControl;
	interface SplitControl as SerialControl; 
	
	interface Receive;
	interface Timer<TMilli> as MilliTimer;
    interface Read<uint16_t> as TempRead;
	interface Read<uint16_t> as HumRead;
  }

} implementation {
  message_t packet;
  message_t serial_packet;
  uint8_t source_mote=0;
  uint16_t temp=0;
  uint16_t hum=0;
  uint16_t temperature=0; // variable with TEMPout from node 1 (used by master)
  uint16_t humidity=0; // variable with HUMout from node 2 (used by master)
  uint16_t counter=0; // for packet_id
  uint16_t rec_id=0;
  bool serial1 = FALSE;
  bool serial2 = FALSE;
  task void SensorTx();
  
//***************** Boot interface ********************//
  
  event void Boot.booted() {
	//printf("app booted \n");
	//printfflush();
	call RadioControl.start(); 
	if ( TOS_NODE_ID==1)
		call SerialControl.start();
  }
  
//*****************  RadioControl interface ********************//
  
  event void RadioControl.startDone(error_t err){
	if (err == SUCCESS) {
		if (TOS_NODE_ID == 2){
			call MilliTimer.startPeriodicAt(1234,2000);
		}
		if (TOS_NODE_ID == 3){
		call MilliTimer.startPeriodicAt(2345,2000);
		}
		else{
			call RadioControl.start();
		}
	}
  }
  event void RadioControl.stopDone(error_t err){};
  
  
//***************** SerialControl interface ********************// 
   
 event void SerialControl.startDone(error_t err) 
 {
   	if(err == SUCCESS) 
	{
		//printf("serial on \n");
		//printfflush();
    	}
    	else
	{
		call SerialControl.start();
    	}
  }
  
  event void SerialControl.stopDone(error_t err) {}
  

//***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	if (TOS_NODE_ID==2){
		call TempRead.read();
	}
	if( TOS_NODE_ID==3){
		call HumRead.read();
	}
  }
  
//********************* AMSend interface ****************//
  event void RadioAMSend.sendDone(message_t* buf,error_t err) {
    if(&packet == buf && err == SUCCESS ) {
		//printf("packet tx \n");
		//printfflush();

	if ( call PacketAcknowledgements.wasAcked( buf ) ) {
		//printf("and ack rx \n");
		//printfflush();
	} 
	else {
		//printf("and ack not rx \n");
		//printfflush();
	}
    }
}
  
//********************* SerialAMSend interface ************************//
  event void SerialAMSend.sendDone(message_t* bufPtr, error_t error){
   	if (&serial_packet == bufPtr) {
		//printf("packet tx over serial \n");
		//printfflush();
      	}
  }
  
//***********************Receive Interface *****************//
 
 event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

	my_msg_t* mess=(my_msg_t*)payload;
	my_serial_msg_t* rcm;
	rec_id = mess->msg_id;
	if (call AMPacket.destination( buf ) == 1){	
		source_mote = call AMPacket.source( buf );
		
		//printf("type rx: %u \n", mess->msg_type);
		//printf("id rx: %u \n", rec_id);
		//printfflush();
		
        if (source_mote==2 && mess->msg_type == TEMP) {
			 temperature= mess->msg_value;
			 //printf("temp value rx: %u \n", temperature);
			 //printfflush();
			 serial1=TRUE;
			 
        }

        if (source_mote==3 && mess->msg_type == HUM) {
			 humidity= mess->msg_value;
			 //printf("hum value rx: %u \n", humidity); 
			 //printfflush();
			 serial2=TRUE;
        }
		
	}
	
 // Forwarding packet to the Serial Port
 
	if(serial1==TRUE){
		
 	    	rcm = (my_serial_msg_t*) call SerialPacket.getPayload(&serial_packet, sizeof(my_serial_msg_t));
			
			if (rcm == NULL){
				return buf;
			}
			
			if (call SerialPacket.maxPayloadLength() < sizeof(my_serial_msg_t)){
				return buf;
	    	}
			
			rcm->msg_type=2; //for node-red
			rcm->msg_id=rec_id;
    		rcm->msg_value=temperature;
			
    		if (call SerialAMSend.send(AM_BROADCAST_ADDR, &serial_packet, sizeof(my_serial_msg_t)) == SUCCESS){	
				
				//printf("temp pack tx to node-red \n");	
				//printfflush();
				
      		}
			
			serial1=FALSE;
     		return buf;
  	}
		
	if(serial2==TRUE){
		rcm = (my_serial_msg_t*) call SerialPacket.getPayload(&serial_packet, sizeof(my_serial_msg_t));
			
		if (rcm == NULL){
			return buf;
		}
		
		if (call SerialPacket.maxPayloadLength() < sizeof(my_serial_msg_t)){
			return buf;
		}
		
		rcm->msg_type=3; //for node-red
		rcm->msg_id=rec_id;
		rcm->msg_value=humidity;
		
		if (call SerialAMSend.send(AM_BROADCAST_ADDR, &serial_packet, sizeof(my_serial_msg_t)) == SUCCESS){
			//printf("hum pack tx to node-red \n");			
			//printfflush();
		}
		
		serial2=FALSE;
		return buf;
	}
	
	else{
 		return buf;
 	} 
	
 }
   
//************************* Read interfaces **********************//
  event void TempRead.readDone(error_t result, uint16_t data) {
	if (result == SUCCESS){
	double x=((double)data/65535)*100;
	temp = (uint16_t)(x+0.5);
	//printf("temp read: %u \n",temp);
	//printfflush();
	post SensorTx();
	 }
  }

  event void HumRead.readDone(error_t result, uint16_t data) {
	if (result == SUCCESS){
	double y=((double)data/65535)*100;
	hum = (uint16_t)(y+0.5);
	//printf("hum read: %u \n",hum);
	//printfflush();
	post SensorTx();
  }
}

//*************************** Send Sensor Data to Sink ************************
  task void SensorTx() {

    my_msg_t* mess=(my_msg_t*)(call RadioPacket.getPayload(&packet,sizeof(my_msg_t)));
    mess->msg_id = counter++;
	if(TOS_NODE_ID==2){ // temperature sensor
		mess->msg_type= TEMP ;
		mess->msg_value= temp ;
		//printf("temp pack tx to sink \n");
		call PacketAcknowledgements.requestAck( &packet );
		if(call RadioAMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS){
			  //printf("type tx: %u \n ", mess->msg_type);
			 // printf("id tx: %u \n", mess->msg_id);
			 // printf("value tx: %u \n", mess->msg_value);
			  //printfflush();
		}
	}
	if(TOS_NODE_ID==3){  // humidity sensor
		mess->msg_type= HUM;
		mess->msg_value= hum;
		//printf("hum pack tx to sink \n");
		call PacketAcknowledgements.requestAck( &packet );
		if(call RadioAMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS){
			  //printf("type tx: %u \n ", mess->msg_type);
			  //printf("id tx: %u \n", mess->msg_id);
			 // printf("value tx: %u \n", mess->msg_value);
			  //printfflush();
		}
	}
  }
 }