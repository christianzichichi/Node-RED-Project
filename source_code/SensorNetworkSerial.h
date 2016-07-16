/**
 *  @author Christian Zichichi
 */

#ifndef SENSOR_NETWORK_SERIAL_H
#define SENSOR_NETWORK_SERIAL_H

typedef nx_struct my_serial_msg  {
	nx_uint8_t msg_type;
	nx_uint16_t msg_id;
	nx_uint16_t msg_value;
} my_serial_msg_t;

enum{
AM_MY_SERIAL_MSG = 0x89,
};

#endif
