/**
 *  @author Christian Zichichi
 */


#include "SensorNetwork.h"
#include "SensorNetworkSerial.h"
//#define NEW_PRINTF_SEMANTICS
//#include "printf.h"

configuration SensorNetworkAppC {}

implementation {

  components MainC, SensorNetworkC as App;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components ActiveMessageC as RadioAM;
  components SerialActiveMessageC as SerialAM; 
  components new TimerMilliC();
  components new TempHumSensorC();
  //components PrintfC;
  //components SerialStartC;

  // Boot interface
  App.Boot -> MainC.Boot;

  // Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.RadioAMSend -> AMSenderC;

  // Radio Control
  App.RadioControl -> RadioAM;

  // Serial Control
  App.SerialControl -> SerialAM;
  App.SerialAMSend -> SerialAM.AMSend[AM_MY_SERIAL_MSG];
  App.SerialPacket -> SerialAM;
  
  // Interfaces to access package fields
  App.AMPacket -> AMSenderC;
  App.RadioPacket -> AMSenderC;
  App.PacketAcknowledgements->RadioAM;
  
  //Timer interface
  App.MilliTimer -> TimerMilliC;

  // Sensor reading
  App.TempRead -> TempHumSensorC.TempRead;
  App.HumRead -> TempHumSensorC.HumRead;
}

