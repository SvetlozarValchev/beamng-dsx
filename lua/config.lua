return {
    CONTROLLER_INDEX = 0,
    ENABLE_ABS = true, -- enable ABS vibration
    ENABLE_BRAKE_SLIP = true, -- enable brake slip vibration
    ENABLE_THROTTLE_SLIP = true, -- enable throttle slip vibration
    ENABLE_DAMAGE_LED = true, -- enable damage LED
    ENABLE_RPM_LED = true, -- enable RPM LED
    ABS_VIBRATION_FREQUENCY = 20, -- frequency of ABS vibration (0-255)
    ABS_WAIT_TIME = 0.25, -- time to wait before activating ABS vibration (seconds)
    BRAKE_SLIP_THRESHOLD = 7, -- wheel slip threshold for brake slip vibration (0-100)
    BRAKE_SLIP_VIBRATION_FREQUENCY = 255, -- frequency of brake slip vibration (0-255)
    BRAKE_VALUE_MIN = 0.1, -- minimum brake value for brake resistance calculation (0-1)
    BRAKE_VALUE_MAX = 0.6, -- maximum brake value for brake resistance calculation (0-1)
    BRAKE_RESISTANCE_MIN = 10, -- minimum brake resistance (0-255)
    BRAKE_RESISTANCE_MAX = 130, -- maximum brake resistance (0-255)
    BRAKE_AIRSPEED_MAX = 60, -- maximum airspeed for brake force calculation (kmh/h)
    BRAKE_FORCE_MIN = 100, -- minimum brake force (0-255)
    BRAKE_FORCE_MAX = 255, -- maximum brake force (0-255)
    THROTTLE_VALUE_MIN = 0.4, -- minimum throttle value for throttle resistance calculation (0-1)
    THROTTLE_VALUE_MAX = 1, -- maximum throttle value for throttle resistance calculation (0-1)
    THROTTLE_RESISTANCE_MIN = 25, -- minimum throttle resistance (0-255)
    THROTTLE_RESISTANCE_MAX = 100, -- maximum throttle resistance (0-255)
    DAMAGE_LED_COLOR = {
        r = 255, -- red component (0-255)
        g = 0, -- green component (0-255)
        b = 0 -- blue component (0-255)
    },
    DAMAGE_BLINK_DURATION = 0.2, -- duration of each blink (seconds)
    DAMAGE_BLINK_COUNT = 10, -- number of blinks
    DAMAGE_THRESHOLD = 500, -- damage threshold for damage LED (0-no limit)
    RPM_LED_ONE_THRESHOLD = 0.75, -- first RPM threshold for RPM LED (0-1)
    RPM_LED_TWO_THRESHOLD = 0.8, -- second RPM threshold for RPM LED (0-1)
    RPM_LED_THREE_THRESHOLD = 0.85, -- third RPM threshold for RPM LED (0-1)
    RPM_LED_FOUR_THRESHOLD = 0.92, -- fourth RPM threshold for RPM LED (0-1)
    RPM_LED_FIVE_THRESHOLD = 0.97 -- fifth RPM threshold for RPM LED (0-1)
}
