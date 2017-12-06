function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');

  outSentence = regexprep(outSentence, '[.!?](?= SENTEND)', ' $0');
  outSentence = regexprep(outSentence, '\.\.+', ' $0 ');
  outSentence = regexprep(outSentence, '(\,|\:|\;|\(|\)|\[|\]|\{|\}|\"|&|\$)', ' $0 ');
  outSentence = regexprep(outSentence, '(\%|<|>|\=|\+|\-|\/|\*)', ' $0 ');
  outSentence = regexprep(outSentence, '\`\`|''''', ' $0 ');
  outSentence = regexprep(outSentence, '\s+', ' ');
  
  switch language
   case 'e'
       outSentence = regexprep(outSentence, '(?<=n)\''t|\''\w', ' $0');
       outSentence = regexprep(outSentence, '\s+', ' ');
   case 'f'
     outSentence = regexprep(outSentence, '\w\''(?=\w)', '$0 ');
     outSentence = regexprep(outSentence, 'qu\''(?=\w)', '$0 ');
     outSentence = regexprep( outSentence, '\w+''(?=on|il)', '$0 ');
     outSentence = regexprep(outSentence, '(d'') (abord|accord|ailleurs|habitude)', '$1$2');
     outSentence = regexprep(outSentence, '\s+', ' ');
  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

