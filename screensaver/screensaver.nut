///////////////////////////////////////////////////
//
// Attract-Mode Frontend -  screensaver script w/ "basic mode" v1.0
// Original AM screensaver modified by Talisto <talisto@gmail.com>
// modified further by Mahuti
//
///////////////////////////////////////////////////

local order = 0 
class UserConfig {
	</ label="Movie-mode timout", 
        help="This screensaver plays random snaps for a period of time until this timeout is activated. Afte the timeout a basic, images only screensaver will be shown to reduce CPU load. Set to 0 to disable this timeout and always play the full movie mode", 
        order=order++ />
	    basic_mode="0";

    </ label="Show TV", 
        help="This will show one of a few different TV/Monitors if set to yes", 
        options="Yes,No", 
        order=order++ />
        show_tv="No";

    </ label="Basic-Mode slideshow type", 
        help="When the movie-mode times out to the basic-mode a slideshow will be shown. Setting this to 'None' will show  a black screen. Choose the images folder to slow slides from. Any movies found will just display the first frame", 
        options="flyer,snap,None" 
        order=order++ />
	    basic_mode_artwork_type="None";

	</ label="Show Specific Video", 
        help="Enter a path to a specific video and it will be played on a loop, overriding the standard randomized snaps. You should probably turn off top & bottom bars as well as ovelay artwork", 
        order=order++/> 
	    show_one_video=""; 
    
	</ label="Preserve Aspect Ratio", 
        help="Preserve the aspect ratio of screensaver snaps/videos", 
        options="Yes,No", 
        order=order++ />
	    preserve_ar="No";

	</ label="Play Sound", 
        help="Play video sounds during screensaver", 
        options="Yes,No", 
        order=order++ />
	    sound="Yes";

    </ label="Overlay Artwork", 
        help="Artwork to overlay on videos", 
        options="wheel,marquee,boxart,cartridge,none", 
        order=order++ />
	   overlay_art="wheel";
    
	</ label="Show Top Bar", 
        help="This will show a transparent black bar with playtime & playcount", 
        options="yes, no", 
        order=order++/> 
	    show_top_bar="yes"; 

	</ label="Show Bottom Bar", 
        help="Shows a transparent black bar in the bottom over which the Overlay Artwork will be shown", 
        options="yes, no", 
        order=order++/> 
	    show_bottom_bar="yes"; 

	</ label="Select Button", 
        help="Show select button & instructions", 
        options="red, yellow, blue, green, white, black, none", 
        order=order++/> 
	    select_button_color="yellow"; 
	
}
local config = fe.get_config()

fe.do_nut(fe.script_dir + "modules/pos.nut" )
fe.load_module("file") 

local base_width = 1440.0
local base_height = 1080.0
// stretched positioning
local posData =  {
    base_width = base_width,
    base_height = base_height,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    scale= "stretch",
    rotate= 0
    debug = false,
}
local stretch = Pos(posData)

// scaled positioning
posData =  {
    base_width = base_width,
    base_height = base_height,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    scale= "scale",
    rotate=0
    debug = false,
}
local scale = Pos(posData)

// tv relative positioning
posData =  {
    base_width = 1166,
    base_height = 655,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    scale= "scale",
    rotate=0
    debug = false,
}
local tv_scale = Pos(posData)
    
function get_new_offset( obj )
{
	// try a few times to get a file
	for ( local i=0; i<6; i++ )
	{
		obj.index_offset = rand()

		if ( obj.file_name.len() > 0 )
			return true
	}
	return false
}
 
 
//
// Container for a wheel image w/ shadow effect
//
class ArtOverlay
{
	logo=0
	logo_shadow=0
	in_time=0
	out_time=0
	playcount = 0 
	playtime = 0 
    arcade_button = 0
    select_button = 0
	top_bar = 0 
	bottom_bar = 0 
	top_bar_surface = 0 
	bottom_bar_surface =0 
	tb_alpha  = 185 
    shadow_offset = 5
    color_selected = "none"
	constructor()
	{
 		if (top_bar_surface == 0)
		{
			top_bar_surface = fe.add_surface( fe.layout.width, fe.layout.height ) 
			top_bar = top_bar_surface.add_image( "black.png", 0, 0, 1,1 )
			top_bar.alpha = tb_alpha 
            
			bottom_bar_surface = fe.add_surface( fe.layout.width, fe.layout.height ) 
			bottom_bar = bottom_bar_surface.add_image( "black.png", 0, 0, 1,1 )
			bottom_bar.alpha = tb_alpha
			if (config["show_bottom_bar"] == "no")
			{
				bottom_bar_surface.alpha = 0 
			}
            if (config["show_top_bar"] == "no")
			{
				top_bar_surface.alpha = 0 
			}
		}

        shadow_offset = 7

        /////////////////////////////////////////////////
        //                 Top Bar
        /////////////////////////////////////////////////
        top_bar.set_pos(0,0)
        top_bar.width = stretch.width(base_width) 
        top_bar.height = stretch.height(76) 
        top_bar.set_rgb(0, 0, 0)
        top_bar.alpha = 0 
        top_bar.visible = true 
            
        /////////////////////////////////////////////////
        //                 Bottom Bar
        /////////////////////////////////////////////////
        bottom_bar.set_pos(0,0)
        bottom_bar.height = stretch.height(176) 
        bottom_bar.width = stretch.width(base_width)
        bottom_bar.y = scale.y(0,"bottom", bottom_bar,null,"bottom")
        bottom_bar.set_rgb(0, 0, 0)
        bottom_bar.alpha = 0 
        bottom_bar.visible = true 

        arcade_button = bottom_bar_surface.add_image("arcade_button_white.png", 0,0,scale.width(150), scale.height(150))
        arcade_button.x = stretch.x(-8,"right", arcade_button, null, "right")
        arcade_button.y = stretch.y(0,"middle",arcade_button,bottom_bar, "middle")
        arcade_button.alpha = 0
        arcade_button.visible = true 

        select_button = bottom_bar_surface.add_text("Press \"Select\" button\n to jump to this game",0,0,100,100)
        select_button.width = stretch.width(260)
        select_button.height = stretch.height(120)
        select_button.x = scale.x(-15,"right", select_button, arcade_button, "left")
        select_button.y = stretch.y(0,"middle",select_button, arcade_button,"middle")

        select_button.font="Hyperspace Bold Italic.otf"
        select_button.set_rgb(86, 155, 195)

        select_button.word_wrap = true
        select_button.charsize= 24
        stretch.set_font_height(22,select_button,"Right")
        select_button.alpha = 0
        select_button.visible = true 
        
        color_selected = config["select_button_color"]
        if ( color_selected != "none")
        {
            switch (color_selected)
            {
                case "red":
                    arcade_button.set_rgb(255,0,0)
                    break
                case "yellow":
                    arcade_button.set_rgb(255,245,0)
                    break
                case "black": 
                    arcade_button.set_rgb(47,47,47)
                    break
                case "white": 
                    break
                case "blue": 
                    arcade_button.set_rgb(0,0,253)
                    break
                case "green": 
                    arcade_button.set_rgb(8,187,4)
                default: 

            }
        }
        
	}
    function random_file(path) {

        local dir = DirectoryListing( path )
        local dir_array = [] 
        foreach ( key, value in dir.results )
        {
            try
            {
                local name = value.slice( path.len() + 1, value.len() )

                // bad mac!
                if (name.find("._") == null)
                {
                    dir_array.append(value) 
                }

            }catch ( e )
            {
                // print(  value )
            }
        }
        return dir_array[random(0, dir_array.len()-1)] 
    }
	function init( index_offset, ttime, duration )
	{        
        in_time = ttime + 1000 // start fade in one second in
        out_time = ttime + duration - 2000

        playcount = top_bar_surface.add_text("Playcount:"+fe.game_info(Info.PlayedCount, index_offset) , stretch.x(8), stretch.y(18), stretch.width(700),stretch.height(24))
        playcount.y = stretch.y(0,"middle", playcount, top_bar, "middle")
        playcount.index_offset = index_offset 
        playcount.visible =  true
        playcount.alpha =  0
        playcount.set_rgb(86, 155, 195)
        playcount.font = "Hyperspace Bold Italic.otf"

        stretch.set_font_height(28,playcount)

        // Playtime
        local py_time = fe.game_info(Info.PlayedTime, index_offset)
        if (py_time.tofloat() > 0)
        {
            py_time = py_time.tofloat()/60
            if (py_time  >=60)
            {
                py_time = py_time.tofloat()/60
                py_time = (py_time + 0.5 ).tointeger() 
                py_time = py_time.tostring() + " H"
            }
            else
            {
                py_time = (py_time + 0.5 ).tointeger() 
                py_time = py_time.tostring() + " M"
            }
        } 
        playtime = top_bar_surface.add_text("Playtime:"+ py_time.tostring(),stretch.x(8), stretch.y(18), stretch.width(700),stretch.height(24))
        playtime.x = stretch.x(-8,"right",playtime,null,"right")
        playtime.y = stretch.y(0,"middle",playtime,top_bar,"middle")
        playtime.index_offset = index_offset
        playtime.visible =  true
        playtime.alpha =  0
        playtime.align = Align.Right
        playtime.charsize = 24
        playtime.set_rgb(86, 155, 195)
        playtime.font = "Hyperspace Bold Italic.otf" 
        stretch.set_font_height(28,playtime,"Right")    
                    
        logo_shadow = bottom_bar_surface.add_artwork( config["overlay_art"],0,0, scale.width(320), scale.height(320  ) )
        logo_shadow.index_offset = index_offset
        logo_shadow.preserve_aspect_ratio = true

        logo = bottom_bar_surface.add_clone( logo_shadow )

        logo_shadow.set_rgb( 0, 0, 0 )
        logo_shadow.visible = logo.visible = false

        logo.height = scale.height(bottom_bar.height - 20)
        logo_shadow.height = scale.height(bottom_bar.height - 20)

        logo.x = scale.x(stretch.x(20),"left",logo,null,"left")
        logo.y = scale.y(0,"middle",logo,bottom_bar,"middle")
        logo_shadow.x = scale.x(scale.x(shadow_offset),"left",logo_shadow,logo,"left")
        logo_shadow.y = scale.y(scale.y(shadow_offset),"middle",logo_shadow,logo,"middle")
        logo.visible = false
        logo_shadow.visible = false
           

            
            
		if ( config["overlay_art"] != "none" )
		{
			logo.visible = logo_shadow.visible = true
			logo.alpha = logo_shadow.alpha = 0
			in_time = ttime + 1000 // start fade in one second in

		}
        if (config["show_top_bar"] =="yes")
        {
            top_bar.visible = true
        }
        if (config["show_bottom_bar"] =="yes")
        {
            bottom_bar.visible = true
        }
        if (config["select_button_color"] !="none")
        {
            arcade_button.visible = true
            select_button.visible = true
        }
	}

	function reset()
	{
		if ( config["show_bottom_bar"] == "yes" )
		{
			logo.visible = logo_shadow.visible = arcade_button.visible = select_button.visible = bottom_bar.visible = false
		}
		if (config["show_top_bar"] == "yes")
		{
			playcount.visible =  playtime.visible = top_bar.visible= false
		}
	}

	function on_tick( ttime )
	{
		if (( config["overlay_art"] != "none" )
			&& ( logo.visible ))
		{
            
			if ( ttime > out_time + 1000 )
			{
				logo.visible = logo_shadow.visible = false
			}
			else if ( ttime > out_time )
			{
				logo.alpha = logo_shadow.alpha = 255 - ( 255 * ( ttime - out_time ) / 1000.0 )
			}
			else if ( ( ttime < in_time + 1000 ) && ( ttime > in_time ) )
			{
				logo.alpha = logo_shadow.alpha = ( 255 * ( ttime - in_time ) / 1000.0 )
			}
		}
		
		if (( config["show_top_bar"] == "yes" )
			&& ( playcount.visible ))
		{
			if ( ttime > out_time + 1000 )
			{
				playcount.visible = playtime.visible = top_bar.visible = false
			}
			else if ( ttime > out_time )
			{
                local al = 255 - ( 255 * ( ttime - out_time ) / 1000.0 )
                playcount.alpha =  playtime.alpha  = al

                if (al < tb_alpha)
                {
                    top_bar.alpha = al                    
                }
                
 			}
			else if ( ( ttime < in_time + 1000 ) && ( ttime > in_time ) )
			{
                local al = ( 255 * ( ttime - in_time ) / 1000.0 )
                playcount.alpha =  playtime.alpha  = al

                if (al < tb_alpha)
                {
                    top_bar.alpha = al                    
                }
 			}
		}
        if (config["select_button_color"] !="none")
        {
			if ( ttime > out_time + 1000 )
			{
				arcade_button.visible = select_button.visible = false
			}
			else if ( ttime > out_time )
			{
				arcade_button.alpha = select_button.alpha =  255 - ( 255 * ( ttime - out_time ) / 1000.0 )
            }
			else if ( ( ttime < in_time + 1000 ) && ( ttime > in_time ) )
			{
				arcade_button.alpha = select_button.alpha = ceil( 255 * ( ttime - in_time ) / 1000.0 )
 			}
        }
        
        if ( config["show_bottom_bar"] == "yes")
		{
			if ( ttime > out_time + 1000 )
			{
				bottom_bar.visible = false
			}
			else if ( ttime > out_time )
			{
                local al = 255 - ( 255 * ( ttime - out_time ) / 1000.0 )
                if (al < tb_alpha)
                {
                    bottom_bar.alpha  = al
                }
 			}
			else if ( ( ttime < in_time + 1000 ) && ( ttime > in_time ) )
			{
                local al = ( 255 * ( ttime - in_time ) / 1000.0 )
                if (al < tb_alpha)
                {
                    bottom_bar.alpha = al                    
                }
 			}
		}
	}
}

//
// Default mode - just play a video through once
//
class MovieMode
{
	MIN_TIME = 4000 // the minimum amount of time this mode should run for (in milliseconds)
	obj=0
	content=0
	start_time=0
	is_exclusive=false
	top_bar = 0 
	playcount = 0 
	playtime = 0 
    tv = null
    tv_image = null
	constructor()
	{
        if (config["show_one_video"] !="")
        {
            MIN_TIME = 50000
            obj = fe.add_image( config["show_one_video"], 0, 0, fe.layout.width, fe.layout.height )
            if ( config["sound"] == "No" )
                obj.video_flags = Vid.NoAudio | Vid.NoAutoStart
            else
                obj.video_flags = Vid.NoAutoStart

            if ( config["preserve_ar"] == "Yes" )
                obj.preserve_aspect_ratio = true

            content = ArtOverlay()        
        }
        else
        {
            obj = fe.add_artwork( "", 0, 0, fe.layout.width, fe.layout.height )
            if ( config["sound"] == "No" )
                obj.video_flags = Vid.NoAudio | Vid.NoAutoStart | Vid.NoLoop
            else
                obj.video_flags = Vid.NoAutoStart | Vid.NoLoop

            if ( config["preserve_ar"] == "Yes" ){
                obj.preserve_aspect_ratio = true
            }

            if (config["show_tv"])
            {
                obj.preserve_aspect_ratio = false
                    
                //local tv_image = random_file(fe.script_dir + "monitors")
                tv_image = fe.script_dir + "monitors/rabbit_ears_full.png"
                tv = fe.add_image(tv_image, 0,0,tv_scale.width(1166), tv_scale.height(655))
                tv.x = tv_scale.x(0,"center",tv)
                tv.y = tv_scale.y(0,"center",tv)

                obj.width = tv_scale.width(620)
                obj.height= tv_scale.height(465)
                obj.x = tv_scale.x(-100,"center", obj,tv,"center")
                obj.y = tv_scale.y(10,"center", obj, tv,"center")

            }

            content = ArtOverlay()        
        }
 	}

	function init( ttime )
	{
		start_time=ttime
		obj.visible = true
		get_new_offset( obj )
		obj.video_playing = true

		content.init( obj.index_offset, ttime, obj.video_duration )
	}

	function reset()
	{
		obj.visible = false
		obj.video_playing = false
		content.reset()
	}

	// return true if mode should continue, false otherwise
	function check( ttime )
	{
		local elapsed = ttime - start_time
		return (( obj.video_playing == true ) || ( elapsed <= MIN_TIME ))
	}

	function on_tick( ttime )
	{
		content.on_tick( ttime )
	}

	function on_select()
	{
		// select the presently displayed game
		fe.list.index += obj.index_offset
	}
}

//
// Movie mode is always on, turn on the others as configured by the user
//
local modes = []
local default_mode = MovieMode()

if ( modes.len() == 0 )
	default_mode.is_exclusive = true

local current_mode = default_mode
local first_time = true


fe.add_ticks_callback( "saver_tick" )

//
// saver_tick gets called repeatedly during screensaver.
// stime = number of milliseconds since screensaver began.
//
function saver_tick( ttime )
{
	if ( first_time ) // special case for initializing the very first mode
	{
		current_mode.init( ttime )
		first_time = false
	}

	if (( config["basic_mode"].tointeger() )
	    && ( (ttime / 1000) >= config["basic_mode"].tointeger() )
	    && ( ! ( current_mode instanceof BasicMode ) ) )
	{
    	current_mode.reset()
    	current_mode = BasicMode(config["basic_mode_artwork_type"])
    	current_mode.is_exclusive = true
    	current_mode.init( ttime )
	}
	else if ( current_mode.check( ttime ) == false )
	{
		//
		// If check returns false, we change the mode
		//
		current_mode.reset()

		current_mode = default_mode
		foreach ( m in modes )
		{
			if ( ( rand() % 100 ) < m.chance )
			{
				current_mode = m
				break
			}
		}
		
 		current_mode.init( ttime )
	}
	else
	{
		current_mode.on_tick( ttime )
	}
}

fe.add_signal_handler( "saver_signal_handler" )

function saver_signal_handler( sig )
{
	if ( sig == "select" )
		current_mode.on_select()

	return false
}



//
// Basic Mode (just show an image slideshow or blank screen)
//
class BasicMode
{
	LENGTH = 12000 // the amount of time this mode should run for (in milliseconds)
	CHANGE_IMAGE_AFTER = 5000 // change the image after this amount of time (in milliseconds)
	obj=0
	start_time=0
	last_switch=0
	is_exclusive=false

	constructor(artwork_type)
	{
        if ( ( artwork_type ) && ( artwork_type != "None" ) )
    	{
    		obj = fe.add_artwork( artwork_type, 0, 0, fe.layout.width / 2, fe.layout.height / 2 )
    		obj.video_flags = Vid.ImagesOnly
			obj.preserve_aspect_ratio = true
    		obj.visible = true
        }
	}

	function init( ttime )
	{
		last_switch = start_time=ttime
    	if (obj)
    	{
    		get_new_offset( obj )
    		obj.x = floor(( 1.0 * rand() / RAND_MAX ) * (fe.layout.width / 2))
    		obj.y = floor(( 1.0 * rand() / RAND_MAX ) * (fe.layout.height / 2))
    	}
	}

	function reset()
	{
    	if (obj)
    	{
        	obj.visible = false
        }
	}

	// return true if mode should continue, false otherwise
	function check( ttime )
	{
		if ( is_exclusive )
			return true
		else
			return (( ttime - start_time ) < LENGTH )
	}

	function on_tick( ttime )
	{
		if (( ttime - last_switch ) > CHANGE_IMAGE_AFTER )
		{
            init( ttime )
		}
	}

	function on_select()
	{
    	if (obj)
    	{
    		// select the presently displayed game
    		fe.list.index += obj.index_offset
        }
	}
}

