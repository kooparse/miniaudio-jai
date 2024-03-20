// Mainly taking from "modules/Sound_Player/core_audio.jai".

#scope_module

AudioToolbox :: #system_library "AudioToolbox";
CoreAudio    :: #system_library "CoreAudio";

AudioUnitElement :: u32;
AudioObjectPropertyAddress :: struct {};

AudioUnitPropertyListenerProc :: *void;
AudioObjectPropertyListenerProc :: *void;

AudioComponentDescription :: struct {
    componentType         : OSType;
    componentSubType      : OSType;
    componentManufacturer : OSType;
    componentFlags        : u32;
    componentFlagsMask    : u32;
}


OpaqueAudioComponent :: struct {}
AudioComponent :: *OpaqueAudioComponent;

ComponentInstanceRecord :: struct {}
AudioComponentInstance :: *ComponentInstanceRecord;
AudioUnit :: AudioComponentInstance;

Boolean :: bool;

AudioObjectID :: u32;

AudioBuffer :: struct {
    mNumberChannels: u32;
    mDataByteSize: u32;
    mData: *void;
}

AudioBufferList :: struct {
    mNumberBuffers: u32;
    mBuffers: [1] AudioBuffer;
}

AudioUnitScope :: enum u32 {
    kAudioUnitScope_Global      :: 0;
    kAudioUnitScope_Input       :: 1;
    kAudioUnitScope_Output      :: 2;
    kAudioUnitScope_Group       :: 3;
    kAudioUnitScope_Part        :: 4;
    kAudioUnitScope_Note        :: 5;
    kAudioUnitScope_Layer       :: 6;
    kAudioUnitScope_LayerItem   :: 7;
}

AudioUnitRenderActionFlags :: enum_flags u32 {
    kAudioUnitRenderAction_PreRender            :: (1 << 2);
    kAudioUnitRenderAction_PostRender           :: (1 << 3);
    kAudioUnitRenderAction_OutputIsSilence      :: (1 << 4);
    kAudioOfflineUnitRenderAction_Preflight     :: (1 << 5);
    kAudioOfflineUnitRenderAction_Render        :: (1 << 6);
    kAudioOfflineUnitRenderAction_Complete      :: (1 << 7);
    kAudioUnitRenderAction_PostRenderError      :: (1 << 8);
    kAudioUnitRenderAction_DoNotCheckRenderArgs :: (1 << 9);
}

SMPTETimeType :: enum u32 {
    kSMPTETimeType24        :: 0;
    kSMPTETimeType25        :: 1;
    kSMPTETimeType30Drop    :: 2;
    kSMPTETimeType30        :: 3;
    kSMPTETimeType2997      :: 4;
    kSMPTETimeType2997Drop  :: 5;
    kSMPTETimeType60        :: 6;
    kSMPTETimeType5994      :: 7;
    kSMPTETimeType60Drop    :: 8;
    kSMPTETimeType5994Drop  :: 9;
    kSMPTETimeType50        :: 10;
    kSMPTETimeType2398      :: 11;
}

SMPTETimeFlags :: enum u32 {
    kSMPTETimeUnknown   :: 0;
    kSMPTETimeValid     :: (1 << 0);
    kSMPTETimeRunning   :: (1 << 1);
}

AudioUnitPropertyID :: enum u32 {
    kAudioUnitProperty_ClassInfo                    :: 0;
    kAudioUnitProperty_MakeConnection               :: 1;
    kAudioUnitProperty_SampleRate                   :: 2;
    kAudioUnitProperty_ParameterList                :: 3;
    kAudioUnitProperty_ParameterInfo                :: 4;
    kAudioUnitProperty_CPULoad                      :: 6;
    kAudioUnitProperty_StreamFormat                 :: 8;
    kAudioUnitProperty_ElementCount                 :: 11;
    kAudioUnitProperty_Latency                      :: 12;
    kAudioUnitProperty_SupportedNumChannels         :: 13;
    kAudioUnitProperty_MaximumFramesPerSlice        :: 14;
    kAudioUnitProperty_ParameterValueStrings        :: 16;
    kAudioUnitProperty_AudioChannelLayout           :: 19;
    kAudioUnitProperty_TailTime                     :: 20;
    kAudioUnitProperty_BypassEffect                 :: 21;
    kAudioUnitProperty_LastRenderError              :: 22;
    kAudioUnitProperty_SetRenderCallback            :: 23;
    kAudioUnitProperty_FactoryPresets               :: 24;
    kAudioUnitProperty_RenderQuality                :: 26;
    kAudioUnitProperty_HostCallbacks                :: 27;
    kAudioUnitProperty_InPlaceProcessing            :: 29;
    kAudioUnitProperty_ElementName                  :: 30;
    kAudioUnitProperty_SupportedChannelLayoutTags   :: 32;
    kAudioUnitProperty_PresentPreset                :: 36;
    kAudioUnitProperty_DependentParameters          :: 45;
    kAudioUnitProperty_InputSamplesInOutput         :: 49;
    kAudioUnitProperty_ShouldAllocateBuffer         :: 51;
    kAudioUnitProperty_FrequencyResponse            :: 52;
    kAudioUnitProperty_ParameterHistoryInfo         :: 53;
    kAudioUnitProperty_NickName                     :: 54;
    kAudioUnitProperty_OfflineRender                :: 37;
    kAudioUnitProperty_ParameterIDName              :: 34;
    kAudioUnitProperty_ParameterStringFromValue     :: 33;
    kAudioUnitProperty_ParameterClumpName           :: 35;
    kAudioUnitProperty_ParameterValueFromString     :: 38;
    kAudioUnitProperty_ContextName                  :: 25;
    kAudioUnitProperty_PresentationLatency          :: 40;
    kAudioUnitProperty_ClassInfoFromDocument        :: 50;
    kAudioUnitProperty_RequestViewController        :: 56;
    kAudioUnitProperty_ParametersForOverview        :: 57;
    kAudioUnitProperty_SupportsMPE                  :: 58;

    kAudioUnitProperty_FastDispatch                 :: 5;
    kAudioUnitProperty_SetExternalBuffer            :: 15;
    kAudioUnitProperty_GetUIComponentList           :: 18;
    kAudioUnitProperty_CocoaUI                      :: 31;
    kAudioUnitProperty_IconLocation                 :: 39;
    kAudioUnitProperty_AUHostIdentifier             :: 46;

    kAudioUnitProperty_MIDIOutputCallbackInfo       :: 47;
    kAudioUnitProperty_MIDIOutputCallback           :: 48;
}

AudioTimeStamp :: struct {
    mSampleTime: float64;
    mHostTime: u64;
    mRateScalar: float64;
    mWordClockTime: u64;
    mSMPTETime: SMPTETime;
    mFlags: AudioTimeStampFlags;
    mReserved: u32;
};

SMPTETime :: struct {
    mSubframes: s16;
    mSubframeDivisor: s16;
    mCounter: u32;
    mType: SMPTETimeType;
    mFlags: SMPTETimeFlags;
    mHours: s16;
    mMinutes: s16;
    mSeconds: s16;
    mFrames: s16;
}

AudioTimeStampFlags :: enum_flags u32 {
    kAudioTimeStampNothingValid         :: 0;
    kAudioTimeStampSampleTimeValid      :: (1 << 0);
    kAudioTimeStampHostTimeValid        :: (1 << 1);
    kAudioTimeStampRateScalarValid      :: (1 << 2);
    kAudioTimeStampWordClockTimeValid   :: (1 << 3);
    kAudioTimeStampSMPTETimeValid       :: (1 << 4);
    kAudioTimeStampSampleHostTimeValid  :: (kAudioTimeStampSampleTimeValid | kAudioTimeStampHostTimeValid);
}
