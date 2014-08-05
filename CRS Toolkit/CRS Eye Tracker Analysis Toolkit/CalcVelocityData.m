function EyeData=CalcVelocityData(EyeData)

    for (i=1:size(EyeData.segment,2))

        % firstly get first derivative for each variable
        diffT=diff([EyeData.segment(i).sampleTime]);
        diffX=diff(EyeData.segment(i).angleX);

        % determine gradient diffX/diffT and diffY/diffT (y2-y1/x2-x1)

        gradX=diffX./diffT;

        % approximation of velocity at t = average of gradient from t-1 -> t
        % and from t -> t+1
        
        win=3;

        % use a filter to calculate moving average using a 3 point window
        % centered on time t to get velocity at each point 
        EyeData.segment(i).velX=filter(ones(1,win)/win,1,gradX);
%        EyeData.segment(i).velX=gradX;
        % because we only have an x coordinate make the velocity an
        % absolute value
        
        
        % generate a new timebase for velocity 1/2 way between each sample
        for (j=1:size(EyeData.segment(i).sampleTime,1)-1)
            diffTime=EyeData.segment(i).sampleTime(j+1)-EyeData.segment(i).sampleTime(j);
            EyeData.segment(i).velTime(j)=EyeData.segment(i).sampleTime(j)+diffTime/2;
            EyeData.segment(i).velTime(j)=round(EyeData.segment(i).velTime(j)*1000)/1000;
        end
        
        EyeData.segment(i).velTime=EyeData.segment(i).velTime'; % make it the same dimensions as the rest of the data
    end

end