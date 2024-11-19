local Triggers = {}

-- TriggerMode Enum
Triggers.TriggerMode = {
    Normal = 0,
    GameCube = 1,
    VerySoft = 2,
    Soft = 3,
    Hard = 4,
    VeryHard = 5,
    Hardest = 6,
    Rigid = 7,
    VibrateTrigger = 8,
    Choppy = 9,
    Medium = 10,
    VibrateTriggerPulse = 11,
    CustomTriggerValue = 12,
    Resistance = 13,
    Bow = 14,
    Galloping = 15,
    SemiAutomaticGun = 16,
    AutomaticGun = 17,
    Machine = 18
}

-- CustomTriggerValueMode Enum
Triggers.CustomTriggerValueMode = {
    OFF = 0,
    Rigid = 1,
    RigidA = 2,
    RigidB = 3,
    RigidAB = 4,
    Pulse = 5,
    PulseA = 6,
    PulseB = 7,
    PulseAB = 8,
    VibrateResistance = 9,
    VibrateResistanceA = 10,
    VibrateResistanceB = 11,
    VibrateResistanceAB = 12,
    VibratePulse = 13,
    VibratePulseA = 14,
    VibratePulsB = 15,
    VibratePulseAB = 16
}

-- Trigger Enum
Triggers.Trigger = {
    Invalid = 0,
    Left = 1,
    Right = 2
}

-- InstructionType Enum
Triggers.InstructionType = {
    Invalid = 0,
    TriggerUpdate = 1,
    RGBUpdate = 2,
    PlayerLED = 3,
    TriggerThreshold = 4,
    MicLED = 5,
    PlayerLEDNewRevision = 6,
}

-- LED Enum
Triggers.PlayerLEDNewRevision = {
    One = 0,
    Two = 1,
    Three = 2,
    Four = 3,
    Five = 4,
    AllOff = 5
}

-- This is the representation of your enums in Lua tables
return Triggers