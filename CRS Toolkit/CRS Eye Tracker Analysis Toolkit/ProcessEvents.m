function Saccades=ProcessSaccades(ASLData)

% process ASL data extracting events which have been tagged

% parameters ASLData structure
% returns array of saccades, fixations and blinks identified 

% process data for saccade events, 
% check if we have saccades in the ASLData
Saccades=[];
Fixations=[];
Blinks=[];saccCount=0;
fixCount=0;

numConds=size(ASLData.segment(1).conditionValues,2);
condCount(1:numConds)=0;

% define saccade structure format


saccadeStruct=struct('segment',[],'saccStartIndex',[],'saccEndIndex',[],'saccDuration',[],'saccAmpX',[],'saccAmpY',[]);
Saccades.perCondition=struct('count',0,'Saccade',saccadeStruct);

for (i=1:numConds)
    Saccades.perCondition(i).count=0;
end


for (i=1:size(ASLData.segment,2))
    startIndex=1;

    % evaluate condition for each sample in the saccade

    maxIndex=size(ASLData.segment(i).sampleTime,1);
    while (startIndex<maxIndex)
        % search for start tagType
        saccStartIndex=find(ASLData.segment(i).tagType(startIndex:maxIndex)=='S',1);

        if (isempty(saccStartIndex)) % go onto the next segment
            break;
        else
            saccStartIndex=startIndex+saccStartIndex-1;
        end

        saccEndIndex=find(ASLData.segment(i).tagType(saccStartIndex:maxIndex)~='S',1);
        if (isempty(saccEndIndex))
            saccEndIndex=maxIndex;
        else
            saccEndIndex=saccStartIndex+saccEndIndex-1; % get real end index for saccade
            saccEndIndex=saccEndIndex-1; % subtract 1 to get end of saccade
        end


        % get condition count for each condition represented in the saccade
        for (j=ASLData.segment(i).conditionValues)
            condCount(j+1)=size(find(ASLData.segment(i).condition(saccStartIndex:saccEndIndex)==j),2);
        end

        % determine actual condition
        maxC=find(condCount==max(condCount));
        if (size(maxC,2)>1) % shared saccade across conditions - mark saccade as unassigned for now
            saccCondition=99; % 99 denotes unassigned
        else % only one condition represented in saccade makes it easy
            saccCondition=maxC-1; % conditions can start at 0 but Matlab arrays can't
        end

        condIndex=saccCondition+1;
        Saccades.perCondition(condIndex).count=Saccades.perCondition(condIndex).count+1;
        count=Saccades.perCondition(condIndex).count;

        Saccades.perCondition(condIndex).Saccade(count).segment=i;
        Saccades.perCondition(condIndex).Saccade(count).saccStartIndex=saccStartIndex;
        Saccades.perCondition(condIndex).Saccade(count).saccEndIndex=saccEndIndex;
        Saccades.perCondition(condIndex).Saccade(count).saccDuration=ASLData.segment(i).sampleTime(saccEndIndex)-ASLData.segment(i).sampleTime(saccStartIndex);

        % get amplitude
        saccStartX=ASLData.segment(i).angleX(saccStartIndex);
        saccEndX=ASLData.segment(i).angleX(saccEndIndex);

        saccStartY=ASLData.segment(i).angleY(saccStartIndex);
        saccEndY=ASLData.segment(i).angleY(saccEndIndex);

        saccDiffX=saccEndX-saccStartX;
        saccDiffY=saccEndY-saccStartY;


        Saccades.perCondition(condIndex).Saccade(count).saccAmpX=saccDiffX;
        Saccades.perCondition(condIndex).Saccade(count).saccAmpY=saccDiffY;

        startIndex=saccEndIndex+1;
    end
        
end

% % process x and y positions
% for (i=1:size(ASLData.segment,1))
%     startIndex=1;
% 
%     maxIndex=size(ASLData.segment(i).sampleTime,1);
%         
%     while (startIndex<maxIndex)
%         % search for start tagType
%         fixStartIndex=find(ASLData.segment(i).tagType(startIndex:maxIndex)=='F',1);
% 
%         if (isempty(fixStartIndex)) % go onto the next segment
%             break;
%         else
%             fixStartIndex=fixStartIndex+startIndex-1;
%         end
%         fixEndIndex=find(ASLData.segment(i).tagType(fixStartIndex:maxIndex)~='F',1);
%         if (isempty(fixEndIndex))
%             fixEndIndex=maxIndex;
%         else
%             fixEndIndex=fixStartIndex+fixEndIndex-1; % get real end index for fixation
%             fixEndIndex=fixEndIndex-1; % subtract 1 to get end of fixation
%         end
% 
%         % add fixation to array
%         fixCount=fixCount+1;
% 
%         Fixations(fixCount).segment=i;
%         Fixations(fixCount).fixStartIndex=fixStartIndex;
%         Fixations(fixCount).fixEndIndex=fixEndIndex;
%         Fixations(fixCount).fixDuration=ASLData.segment(i).sampleTime(fixEndIndex)-ASLData.segment(i).sampleTime(fixStartIndex);
%         fixPointX=median(ASLData.segment(i).angleX(fixStartIndex:fixEndIndex));
%         fixPointY=median(ASLData.segment(i).angleY(fixStartIndex:fixEndIndex));
% 
%         Fixations(fixCount).fixPointX=fixPointX;
%         Fixations(fixCount).fixPointY=fixPointY;
% 
%         % set fixation condition
%         startIndex=fixEndIndex+1;
%     end
%         
% end

end
