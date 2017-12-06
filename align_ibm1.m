function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to  save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

%   % Iterate between E and M steps
  for iter=1:maxIter
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
eng = {};
fre = {};
line_counter = 0;
DE = dir( [ mydir, filesep, '*','e'] );
DF = dir( [ mydir, filesep, '*','f'] );
for iFile=1:length(DE)
    %Get every line as a list for both the english and french files
    lines_e = textread([mydir, filesep, DE(iFile).name], '%s','delimiter','\n');
    lines_f = textread([mydir, filesep, DF(iFile).name], '%s','delimiter','\n');
    %Loop through every line
    for l=1:length(lines_e)
        if line_counter == numSentences
           break; 
        end
        %Append a list of words for that sentence into its corresponding
        %language list
        eng{l} = strsplit(' ', preprocess(lines_e{l}, 'e'));
        fre{l} = strsplit(' ', preprocess(lines_f{l}, 'f'));
        
        line_counter = line_counter + 1;
    end
    if line_counter == numSentences
        break; 
    end
end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = struct(); % AM.(english_word).(foreign_word)
    storage = struct();
    
    %Loop through every sentence
    for line_idx=1:(length(eng))
        % Loop through every english word in that sentence
        for e_wrd_idx=1:(length(eng{line_idx}))
            eng_word = eng{line_idx}{e_wrd_idx};
            
            for f_wrd_idx=1:(length(fre{line_idx}))
                fre_word = fre{line_idx}{f_wrd_idx};
                
                if ~isfield(AM, eng_word)
                    AM.(eng_word) = struct();
                    storage.(eng_word) = {};
                end 
                storage.(eng_word) = [storage.(eng_word), fre{line_idx}(2:end-1)];
                
            end
        end
    end
    
    eng_words_lst = fieldnames(storage);

    % Set the right probability for each french word given an english word
    for i=1:length(eng_words_lst)
        [french_lst] = unique(storage.(eng_words_lst{i}));
        for j=1:length(french_lst)
            AM.(eng_words_lst{i}).(french_lst{j}) = 1/length(french_lst);
        end
    end
    
    AM.SENTSTART = struct();
    AM.SENTEND = struct();
    
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  tcount= struct();
  total = struct();
  
  for line_index = 1:length(eng)
      [f_uniq, f_index, f_order] = unique(fre{line_index}(2:end-1));
      [e_uniq, e_index, e_order] = unique(eng{line_index}(2:end-1));
      fre_count = hist(f_order, 1:max(f_order));
      eng_count = hist(e_order, 1:max(e_order));
      
      for f_idx=1:length(f_uniq)
          denom_c = 0;
          fre_word_count = fre_count(f_idx);
          
          for e_idx=1:length(e_uniq)
              
             if isfield(t.(e_uniq{e_idx}), f_uniq{f_idx}) 
                 denom_c = denom_c + t.(e_uniq{e_idx}).(f_uniq{f_idx}) * fre_word_count; 
             end
             
             if ~isfield(tcount, e_uniq{e_idx}) || ~isfield(tcount.(e_uniq{e_idx}), f_uniq{f_idx})
                  tcount.(e_uniq{e_idx}).(f_uniq{f_idx}) = 0;
             end
              
             if ~isfield(total, e_uniq{e_idx})
                 total.(e_uniq{e_idx}) = 0;
             end
          end
          
          for e_idx=1:length(e_uniq)
              eng_word_count = eng_count(e_idx);
              if isfield(t.(e_uniq{e_idx}), f_uniq{f_idx})
                 tcount.(e_uniq{e_idx}).(f_uniq{f_idx}) = tcount.(e_uniq{e_idx}).(f_uniq{f_idx}) + ((t.(e_uniq{e_idx}).(f_uniq{f_idx})  * fre_word_count  * eng_word_count)  / denom_c);
                 total.(e_uniq{e_idx}) =  total.(e_uniq{e_idx}) + ((t.(e_uniq{e_idx}).(f_uniq{f_idx}) * fre_word_count  * eng_word_count)  / denom_c);
              end
          end
      end
  end
    
  
 fields = fieldnames(total); 
 for e_idx = 1:numel(fields)
    nest_fields = fieldnames(t.(fields{e_idx})); 
    for f_idx = 1:numel(nest_fields)
        if isfield(t.(fields{e_idx}), nest_fields{f_idx}) && ~strcmp(fields{e_idx}, nest_fields{f_idx})
            t.(fields{e_idx}).(nest_fields{f_idx}) =  tcount.(fields{e_idx}).(nest_fields{f_idx}) / total.(fields{e_idx}); 
        end
        if isfield(t.(fields{e_idx}), nest_fields{f_idx}) && strcmp(fields{e_idx}, nest_fields{f_idx})
            t.(fields{e_idx}).(nest_fields{f_idx}) = 1;
        end
    end
 end
 
end


