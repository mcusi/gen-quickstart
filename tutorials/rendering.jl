using DSP

#Frequency scale conversions
function freq_to_ERB(freq)
    return 9.265*log.(1 .+ freq./(24.7*9.265))
end

function ERB_to_freq(ERB)
    return 24.7*9.265*(exp.(ERB./9.265) .- 1)
end

function hann_ramp(x::Array{Float64,1}, sr::Int)
    #= Applies a hann window to a soundwave s so s has gradual onsets & offsets
    x: soundwave
    sr (samples/sec)
    
    Parameters
    ----------
    ramp_duration (sec): duration of onset = duration of offset
    
    =#

    #Set parameters
    ramp_duration = 0.010
    
    #Make ramps
    t = 0:1/sr:ramp_duration
    n_samples = size(t)[1]
    off_ramp = 0.5*(ones(n_samples) + cos.( (pi/ramp_duration)*t ))
    on_ramp = off_ramp[end:-1:1]

    #Apply ramps
    x[1:n_samples] .*= on_ramp
    x[end-n_samples+1:end] .*= off_ramp

    return x

end

function generate_tone_wave(erbf0::Float64, onset::Float64, offset::Float64, audio_sr::Int, scene_duration::Float64)
    
    n_samples = Int(floor(scene_duration*audio_sr)); scene_wave = zeros(n_samples);

    if onset >= scene_duration
        return scene_wave
    end
    
    
    # render the waveform for the tone
    duration = offset - onset; 
    A = 1e-6 * 10.0 .^( 60. /20. ) .- 1e-12 #Constant amplitude at 60dB
    timepoints = 0:(1/audio_sr):duration
    element_wave = A*sin.(2*pi*ERB_to_freq(erbf0)*timepoints)
    element_wave = hann_ramp(element_wave, audio_sr)
    
    ## Place the tone waveform into the overall scene register
    sample_start = max(1, Int(floor(onset*audio_sr)));
    if sample_start < n_samples
        sample_finish = min(sample_start + length(element_wave), length(scene_wave))
        scene_wave[sample_start:sample_finish-1] = element_wave[1:length(sample_start:sample_finish-1)]
    end

    return scene_wave
    
end;

