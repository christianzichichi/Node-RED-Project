/**
 *  @author Christian Zichichi
 */

#ifndef SENSOR_NETWORK_H
#define SENSOR_NETWORK_H

typedef nx_struct my_msg {
	nx_uint8_t msg_type;
	nx_uint16_t msg_id;
	nx_uint16_t msg_value;
} my_msg_t;

#define TEMP 2
#define HUM 3

enum{
AM_MY_MSG = 6,
};

#endif
