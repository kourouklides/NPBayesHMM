function [] = RunMocapBIGExperiment( jobID, taskID, infName, initName, TimeLimit, Scoef )
%INPUT
%  jobID : integer/name of job
%  taskID : integer/name of task
%  infName  : {'Prior','DD','SM'} indicates type of sampler     
%  initName : {'one', 'unique5'}  indicates initialization
%  TimeLimit : # of seconds to allow for MCMC

if ~exist( 'Scoef', 'var' )
    Scoef = 0.5;
end

dataP = {'MocapBIG'};
modelP = {'obsM.Scoef', Scoef};

TimeLimit = force2double( TimeLimit );
T0 = 50;
Tf = 1000;
switch infName
    case 'Prior'
        algP = {'doSampleFUnique', 1, 'doSplitMerge', 0, 'RJ.birthPropDistr', 'Prior'};         
    case {'DD', 'DataDriven'}
        algP = {'doSampleFUnique', 1, 'doSplitMerge', 0, 'RJ.birthPropDistr', 'DataDriven'};  
    case {'zDD'}
        algP = {'doSampleFUnique', 0, 'doSampleUniqueZ', 1, 'doSplitMerge', 0, 'RJ.birthPropDistr', 'DataDriven'};       
    case 'SM'                
        algP = {'doSampleFUnique', 0, 'doSplitMerge', 1};         
    case 'SM+DD'               
        algP = {'doSampleFUnique', 1, 'doSampleUniqueZ', 0, 'doSplitMerge', 1, 'RJ.birthPropDistr', 'DataDriven'};                      
    case 'SM+zDD'               
        algP = {'doSampleFUnique', 0, 'doSampleUniqueZ', 1, 'doSplitMerge', 1, 'RJ.birthPropDistr', 'DataDriven'};       
    case 'SM+DD+Anneal'        
        algP = {'doSampleFUnique', 1, 'doSampleUniqueZ', 0, 'doSplitMerge', 1, 'RJ.birthPropDistr', 'DataDriven', 'doAnneal', 1, 'Anneal.T0', T0, 'Anneal.Tf', Tf};      
    case 'SM+zDD+AnnealExp'        
        algP = {'doSampleFUnique', 0, 'doSampleUniqueZ', 1, 'doSplitMerge', 1, 'RJ.birthPropDistr', 'DataDriven', 'doAnneal', 'Exp', 'Anneal.T0', T0, 'Anneal.Tf', Tf};               
    case 'SM+zDD+AnnealLin'        
        algP = {'doSampleFUnique', 0, 'doSampleUniqueZ', 1, 'doSplitMerge', 1, 'RJ.birthPropDistr', 'DataDriven', 'doAnneal', 'Lin', 'Anneal.T0', T0, 'Anneal.Tf', Tf};               
    % NON VALID OPTIONS (for experiments only)
    case 'SMnoqrev'               
        algP = {'doSampleFUnique', 0, 'doSMNoQRev', 1}; 
    case 'SMnoqrev+DD'               
        algP = {'doSampleFUnique', 1, 'doSMNoQRev', 1, 'theta.birthPropDistr', 'DataDriven'}; 
    otherwise
        error( 'unrecognized inference type' );
end
algP(end+1:end+2) = {'TimeLimit', TimeLimit};


switch initName
    case 'cheat'
        initP = {'InitFunc', @initBPHMMCheat, 'Cheat.nRepeats', 1};
    case {'seq','seq2'}
        initP = {'InitFunc', @initBPHMMSeq, 'F.nUniquePerObj', 2, 'nSubsetObj', 20};
    case 'one'
        initP = {'F.nTotal', 1};
    case 'unique5'
        initP = {'F.nUniquePerObj', 5};
end

runBPHMM( dataP, modelP, {jobID, taskID}, algP, initP );
