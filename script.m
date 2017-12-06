%
% This Script is meant to create a translation of the 25 lines below.
% 
% It runs on 1k, 10k, 15k, and 30k lines of training data each with 100
% iterations. 
%
% If the AMs for each iteration do not exist it creates them.
%

fsents = {'Dans le monde reel, il n''y a rien de mal a cela.',
'Cela vaut pour tous les deputes.',
'Je ne pense pas que ce soit la notre objectif.',
'Que tous ceux qui appuient la motion veuillent bien dire oui.',
'Le bonne nouvelle est que Postes Canada est tout ouie.',
'La question se pose donc, pourquoi?',
'Les deputes liberaux sont nombreux a representer des circonscription rurales.',
'Nous vivons dans une democratie.',
'C''est le comble du ridicule',
'A mon avis, les non l''emportent',
'Tous les deputes de tous les partis connaissent bien ces programmes',
'Nous n''avons pas l''intention de mettre fin a cela.',
'Tachons d''honorer nos engagements de Kyoto.',
'Le ministre des Finances a sabre a tour de bras dans les transferts aux provinces.'
'Mais laissons cela et entrons dans le coeur du debat.',
'Nous estimons qu''il est possible de faire mieux.',
'C''est le plus pur style liberal.',
'Nous y revoila, et le premier ministre va determiner qui est le president du conseil.',
'Il est clair que cela constituerait un conflit d''interets.',
'Nous nous rejouissons de ces nouvelles perspectives.',
'Je declare la motion rejetee.',
'Et plus de cinq deputes s''etant leves:',
'Je ne crois pas que ce soit la solution du probleme.',
'Je felicite le depute de Winnipeg-Centre d''avoir presente ce projet de loi.',
'Il faut que ca change.'};

if exist('am.mat', 'file') ~= 2
    disp('Running 1K AM')
    align_ibm1('/u/cs401/A2_SMT/data/Hansard/Training', 1000, 100, 'am')
end
if exist('am-10000.mat', 'file') ~= 2
    disp('Running 10K AM')
    align_ibm1('/u/cs401/A2_SMT/data/Hansard/Training', 10000, 100, 'am-10000.mat')
end
if exist('am-15000.mat', 'file') ~= 2
    disp('Running 15K AM')
    align_ibm1('/u/cs401/A2_SMT/data/Hansard/Training', 15000, 100, 'am-15000.mat')
end
if exist('am-30000.mat', 'file') ~= 2
    disp('Running 30K AM')
    align_ibm1('/u/cs401/A2_SMT/data/Hansard/Training', 30000, 100, 'am-30000.mat')
end

AM1000 = load('am.mat');
AM10000 = load('am-10000.mat');
AM15000 = load('am-15000.mat');
AM30000 = load('am-30000.mat');
AMs = {AM1000.AM, AM10000.AM, AM15000.AM, AM30000.AM};
nums = {1000, 10000, 15000, 30000};
load('e_training.mat');
vocabSize = numel(fieldnames(LM.uni));

for iAMs=1:numel(AMs)
    filename = strcat('candidates-', num2str(nums{iAMs}), '.txt');
    fid = fopen(strcat('candidates-', num2str(nums{iAMs}), '.txt'), 'w');
    for iSentsFr=1:numel(fsents)
        decoded_sent = decode2(fsents{iSentsFr}, LM, AMs{iAMs}, '', 0, vocabSize);
        fprintf(fid, strcat(decoded_sent, '\n'));
    end
end