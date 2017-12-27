
% define the act to detect,to add class have to add here first
classdef Act < uint32
   enumeration
      Walking (1)
      WalkingUpstairs (2)
      WalkingDownstairs (3)
      Sitting (4)
      Standing (5)
      Laying (6)
      DragLimp (7)
      JumpLimp (8)
      PersonFall (9)
      PhoneFall (10)
      Running(11)
      AustoLimp(12)
   end
end