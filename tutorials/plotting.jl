using PyPlot;
using PyCall
gspec = pyimport("matplotlib.gridspec")
using Gen;
include("./gammatonegram.jl")

function plot_gtg(gtg, duration, audio_sr, vmin, vmax;colors="Blues",plot_colorbar=true)
    max_freq=audio_sr/2
    imshow(gtg, cmap=colors, origin="lower", extent=(0, duration, 0, max_freq),vmin=vmin, vmax=vmax, aspect="auto")
    locs, labels = yticks();
    lowlim = freq_to_ERB(1.)
    hilim = freq_to_ERB(max_freq)
    fs = Int.(floor.(ERB_to_freq(range(lowlim, stop=hilim, length=length(locs)))))
    setp(gca().set_yticklabels(fs), fontsize="small")
    if plot_colorbar
        plt.colorbar()
    end
end

function plot_sources(trace, obs_gram, trace_idx; save=false, colors="Blues", save_loc="./")
    
    scene_duration, audio_sr, wts, gtg_params = get_args(trace)
    scene_gram, scene_wave, source_waves = get_retval(trace)
    s = round(get_score(trace),digits=2)
                       
    ##First plot reconstruction and observation
    fig = plt.figure()
    gs1 = gspec.GridSpec(1,2)
    gs1.update(top=0.90, bottom=0.60)
    ax1 = plt.subplot(get(gs1, (0,0))); plot_gtg(scene_gram, scene_duration, audio_sr,gtg_params.dBthreshold,100.0,colors=colors,plot_colorbar=false); title("sample $trace_idx, score $s") 
    ax2 = plt.subplot(get(gs1, (0,1))); plot_gtg(obs_gram, scene_duration, audio_sr,gtg_params.dBthreshold,100.0,colors=colors,plot_colorbar=false); title("ground truth") 
                    
    ##Plot each source separately to visualize contributions
    n_sources = trace[:n_sources]
    grid_height = Int(ceil(n_sources/2))
    gs2 = gspec.GridSpec(grid_height, 2)
    gs2.update(top=0.50, bottom=0.10, hspace=0.0)
    ax3 = plt.subplot(get(gs2, (0,0)));
    for i = 1:n_sources
        gtg, t = gammatonegram(source_waves[i], wts, audio_sr,gtg_params)  
        if i > 1
            #subplot(ceil(n_sources/2), 2, i, sharex=ax1)
            c = Int(mod(i, 2) == 0 ? 1 : 0)
            r = Int((mod(i, 2) == 0 ? i/2 : (i+1)/2) - 1)
            ax = plt.subplot(get(gs2, (r,c)), sharex=ax3);
        end
        ax = gca()
        plot_gtg(gtg, scene_duration, audio_sr,gtg_params.dBthreshold,100.0,colors=colors,plot_colorbar=false)
        setp(ax.get_xticklabels(),visible=false)
        setp(ax.get_yticklabels(),color="white")
    end
    
    if save
        savefig(string(save_loc,"sample", trace_idx,".svg"))
        PyPlot.close()
    else
        plt.show()
    end
    
end