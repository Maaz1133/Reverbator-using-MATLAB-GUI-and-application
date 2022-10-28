
fileReader = dsp.AudioFileReader('Filename','C:\Program Files\Polyspace\R2021a\toolbox\audio\samples\RockGuitar-16-44p1-stereo-72secs.wav');
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);

% Create scopes
h = timescope('SampleRate',fileReader.SampleRate, ...
    'TimeSpanSource','Property', ...
    'TimeSpan',1, ...
    'TimeSpanOverrunAction','Scroll', ...
    'AxesScaling','Manual', ...
    'PlotType','Line', ...
    'BufferLength',4*fileReader.SampleRate, ...
    'TimeUnits','Metric', ...
    'TimeAxisLabels','All', ...
    'MaximizeAxes','Auto', ...
    'ShowLegend',true, ...
    'ChannelNames',{'Input channel 1','Output channel 1'}, ...
    'YLimits',[-1 1]);
specScope = dsp.SpectrumAnalyzer('SampleRate',fileReader.SampleRate, ...
    'PlotAsTwoSidedSpectrum',false, ...
    'FrequencyScale','Log', ...
    'ShowLegend',true, ...
    'ChannelNames',{'Input channel 1','Output channel 1'});


% Set up the system under test
sut = StereoWidth1;
setSampleRate(sut,fileReader.SampleRate);

% Open parameterTuner for interactive tuning during simulation
tuner = parameterTuner(sut);
drawnow

% Stream processing loop
nUnderruns = 0;
while ~isDone(fileReader)
    % Read from input, process, and write to output
    in = fileReader();
    out = process(sut,in);
    nUnderruns = nUnderruns + deviceWriter(out);
    
    % Visualize input and output data in scopes
    h([in(:,1),out(:,1)]);
    specScope([in(:,1),out(:,1)]);
    
    % Process parameterTuner callbacks
    drawnow limitrate
end

% Clean up
release(fileReader)
release(deviceWriter)
release(h)
release(specScope)

