
#pragma BEGINDUMP

#include "hbapi.h"
#include "allegro.h"
HB_FUNC(SCARE_MOUSE)
{
   scare_mouse();
}

HB_FUNC(UNSCARE_MOUSE)
{
   unscare_mouse();
}

HB_FUNC(SHOW_MOUSE)
{
   show_mouse((BITMAP *)hb_parnl(1));
}

HB_FUNC(HIDE_MOUSE)
{
   show_mouse(NULL);
}

HB_FUNC(SHOW_OS_CURSOR)
{
   hb_retni(show_os_cursor(hb_parni(1)));
}

HB_FUNC(MOUSE_X)
{
	hb_retnl(mouse_x);	
}

HB_FUNC(MOUSE_Y)
{
	hb_retnl(mouse_y);	
}


HB_FUNC(MOUSE_Z)
{
	hb_retnl(mouse_z);	
}

HB_FUNC(POSITION_MOUSE_Z)
{
	position_mouse_z(hb_parni(1));
}

HB_FUNC(SELECT_MOUSE_CURSOR)
{
   select_mouse_cursor(hb_parni(1));
}

HB_FUNC(MOUSE_DRIVER)
{
  hb_retc(mouse_driver->name);
}


HB_FUNC(SET_MOUSE_RANGE)
{
   int x1=hb_parni(1);
   int y1=hb_parni(2);
   int x2=hb_parni(3);
   int y2=hb_parni(4);
   set_mouse_range(x1,y1,x2,y2);
}

HB_FUNC(MIDDLE_MOUSE_BUTTON)
{
   poll_mouse();
   hb_retl(mouse_b & 4);
}

HB_FUNC(LEFT_MOUSE_BUTTON)
{
   poll_mouse();
   hb_retl(mouse_b & 1);
}

HB_FUNC(RIGHT_MOUSE_BUTTON)
{
   poll_mouse();
   hb_retl(mouse_b & 2);
}


HB_FUNC(ENABLE_HARDWARE_CURSOR)
{
   enable_hardware_cursor();
}

HB_FUNC(DISABLE_HARDWARE_CURSOR)
{
   disable_hardware_cursor();
}

HB_FUNC(SET_MOUSE_SPEED)
{
   int x=hb_parni(1);
   int y=hb_parni(2);
   set_mouse_speed(x,y);
}

HB_FUNC(POSITION_MOUSE)
{
   int x=hb_parni(1);
   int y=hb_parni(2);
   position_mouse(x,y);
}

HB_FUNC(SET_MOUSE_SPRITE)
{
   BITMAP *sprite=(BITMAP *)hb_parnl(1);
   set_mouse_sprite(sprite);
}

#pragma ENDDUMP