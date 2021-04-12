function [this,particles] = getparticles(this,micrograph,radius,idx,binning)

imagesize = size(micrograph);
radius = radius./2^binning;
particles = zeros(radius*2,radius*2,size(idx,2),'single');

l = 1;
for i=idx
    x = round(this.position.x(i)./2^binning);
    y = round(this.position.y(i)./2^binning);
    
    if x <= radius || y <= radius || x > imagesize(1)-radius-1 || y > imagesize(2)-radius-1

        lowx = x-radius;
        lowy = y-radius;
        highx = x+radius-1;
        highy = y+radius-1;

        %set x or y to 1 if particle is in the left or upper edge
        if x <= radius
            lowx = 1;
        end
        if y <= radius
            lowy = 1;
        end

        %set x or y to size of image if particle is in the right or lower edge
        if x > imagesize(1)-radius-1
            highx = imagesize(1);
        end
        if y > imagesize(2)-radius-1
            highy = imagesize(2);
        end

        %cut out particle, this will give a non quadratic matrix
        %part_box = tom_emreadc2([alignstruct(1,i).filename],'subregion',[lowx lowy 1],[highx-lowx highy-lowy 0]);
        %part_box = single(part_box.Value);
        part_box = micrograph(lowy:highy,lowx:highx);
        
        %taper in x direction
        if size(part_box,1) < radius*2
            if lowx == 1
                stripe = part_box(1,:);
                while size(part_box,1) < radius*2
                    part_box = cat(1,stripe(randperm(length(stripe))),part_box);
                end
            else
                stripe = part_box(size(part_box,1),:);
                while size(part_box,1) < radius*2
                    part_box = cat(1,part_box,stripe(randperm(length(stripe))));
                end
            end
        end
        %taper in y direction
        if size(part_box,2) < radius*2
            if lowy == 1
                stripe = part_box(:,1);
                while size(part_box,2) < radius*2
                    part_box = cat(2,stripe(randperm(length(stripe))),part_box);
                end
            else
                stripe = part_box(:,size(part_box,2));
                while size(part_box,2) < radius*2
                    part_box = cat(2,part_box,stripe(randperm(length(stripe))));
                end
            end
        end

        particles(:,:,l) = part_box;
    else
        %particle = tom_emreadc(alignstruct(1,i).filename,'subregion',[x-2*radius y-2*radius 1],[4*radius-1 4*radius-1 0]);
        %particle = single(particle.Value);
        particles(:,:,l) = micrograph(x-radius:x+radius-1,y-radius:y+radius-1);
    end

    %reduce to final size
    %particles(:,:,l) = particle(radius:3*radius-1,radius:3*radius-1);
    l = l + 1;
end