function this = calc_powerspectrum(this,average)

if isempty(this.powerspectrum) || this.ps_average ~= average

    if average ~= 1
        im = single(this.image.Value);
        this.powerspectrum = zeros(size(im)./average,'single');
        for i=1:average
            if i==1
                im_old=im;
            end
            im = split_image(im_old,average,i);
            ps = tom_ps(tom_smooth(im,32));
            this.powerspectrum = this.powerspectrum + ps;
        end
    else
        this.powerspectrum = tom_ps(tom_smooth(single(this.image.Value),32));
    end

   this.ps_average = average; 

end

function split_image=split_image(im,number_of_splits,split_nr)

im_sz=size(im,1);
inkre=round(im_sz./number_of_splits);
start=((split_nr-1).*inkre)+1;
stop=split_nr.*inkre;
split_image=im(start:stop,start:stop);