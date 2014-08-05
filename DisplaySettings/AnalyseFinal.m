

LumFile{1} = 'LeftEye_2013-06-21.mat';
LumFile{2} = 'RightEye_2013-06-21.mat';
PlotColor = {'*r','+b'};
for e = 1:2
    load(LumFile{e});
    Results = sortrows([Lum.SampleOrder, Lum.Measurement'],1);
    Levels = unique(Results(:,1));
    MeanLuminances(:,e) = Results(:,2);
    plot(Levels, MeanLuminances(:,e), PlotColor{e})
    hold on;
end


LumDiff = MeanLuminances(:,1)-MeanLuminances(:,2);
Figure;
plot(Levels, LumDiff, '.k');