//
//  config.h
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef desmond_project_config_h
#define desmond_project_config_h

#define TIMESTEP    15
#define FOUR_MIN 60*4
#define MINIMUM_TIME    60
#define ONE_HOUR 60*60
#define ONE_DAY 60*60*24

#define LEVELS_UNDER_FOUR_MINS 2
#define LEVELS_UNDER_HOUR 6

#define INPUT_WINDOW   FOUR_MIN

#define BUZZER_TIME  5

#define TICK_FILE_PATH  @"tick"
#define STILL_ALIVE_FILE_PATH  @"stillAlive"
#define DEATH_SOUND @"death"
#define SOUND_TYPE      @"wav"


#endif
