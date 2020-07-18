open Proj2_types;;

let getStartSymbol (g : grammar) : string = match g with
    | (h, t) -> h
;;

let getNonterminals (g : grammar) : string list = match g with
(*The non-terminals are just the LHS of every rule in the tuple of the grammar*)
  |(hd, tl) -> let rec helper l acc = match l with
                | [] -> acc (*empty helper list which will be our result*)
                | (a,b) :: c -> (* (a,b) is like (h::t) but for a tuple*)
                  let acc' = acc@[a] in (*append the first element (aka the LHS) to the acc list*)
                        helper c acc'
                in
                helper tl []
;;

let getInitFirstSets (g : grammar) : symbolMap = match g with
(*Will just initialize empty smaps to add the first sets into*)
  | (h,t) -> let rec temp l  fmap = match l with
              | [] -> fmap
              | (a,b)::c -> let x = SMap.add a (SymbolSet.empty) fmap in temp c x
              in temp t SMap.empty
;; 

let getInitFollowSets (g : grammar) : symbolMap = match g with
  (*fmap is our accumulator symbol map*)
    | (h,t) -> let rec firstfollow l fmap = match l with
                  | [] -> fmap
                  | (a,b)::c ->
                    if h <> a (* <> means != *)
                    then  
                    
                      let x = SMap.add a (SymbolSet.empty) fmap in firstfollow c x
                    
                    else
                    
                    let x = SMap.add a (SymbolSet.singleton "eof") fmap in firstfollow c x

                   in firstfollow t SMap.empty 
 
;;
let computeFirstSet (first : symbolMap) (symbolSeq : string list) : SymbolSet.t = 
(*we can make an accumlator function to produce a valid output*)
  let rec compute s accum =
      match s with
      
      | [] -> SymbolSet.add "eps" accum
      (*break the symbolSeq apart and check that its inside the map*)
      | (head::tail) ->
            (*this will then check to see that the symbol map head is in the map itself*)
              if (SMap.mem head first) then 
              (
                (*following First set rules, we will union the resulting symbols with our accm after subtracting hte epsilon*)
                      if (SymbolSet.mem "eps" (SymbolSet.union (SMap.find head first) accum)) then
                        compute tail (SymbolSet.remove "eps" (SymbolSet.union (SMap.find head first) accum))
                      else  
                      (*if there's no epsilon, just return whatever the map key was pointing to*)
                        SymbolSet.union (SMap.find head first) accum
              )
              else 
                  SymbolSet.singleton head

  in let accum = SymbolSet.empty
  in compute symbolSeq accum
  ;;

let recurseFirstSets (g : grammar) (first : symbolMap) firstFunc : symbolMap =
  (*to make this easier to understand, we need to first break this grammar down and iterate by each rule*)
      let rec recurseFirstSetsHelper first firstFunc rule_list = match rule_list with 
      | [] -> first 
      | r1::rs -> match r1 with (lhs,rhs) -> 
                                      let first' = SMap.add lhs ( SymbolSet.union (SMap.find lhs first) (firstFunc first rhs) ) first  in
                                      
                                      recurseFirstSetsHelper first' firstFunc rs
                                            in
                                                  let rule_list = (snd g)
                                                  in recurseFirstSetsHelper first firstFunc rule_list 
                                                  ;;



let rec getFirstSets (g : grammar) (first : symbolMap) firstFunc : symbolMap =

    let new_first = recurseFirstSets g first computeFirstSet
    in 
        if (SMap.equal (SymbolSet.equal) new_first first) then
            first
        else
          getFirstSets g new_first computeFirstSet
;;

let rec updateFollowSet (first : symbolMap) (follow : symbolMap) (nt : string) (symbolSeq : string list) : symbolMap = 
match symbolSeq with
(*if its an empty set then just output the follow set as is *)
|[] -> follow 
(*if its something other than an empty set *)
|[_] -> if SMap.mem (List.hd symbolSeq) first then
(*smap.add key value map*)
  SMap.add (List.hd symbolSeq) (SymbolSet.union (SMap.find (List.hd symbolSeq) follow) (SMap.find nt follow)) follow
  else follow
  (*break the sequence into its respective hd and tail*)
|h::t -> if SMap.mem h first then 
(*check inside the first set for the same symbol*)
  if SymbolSet.mem "eps" (computeFirstSet first t) then (*if epsilon is in the first set of this symbolmap*)
  updateFollowSet first (SMap.add h (SymbolSet.union (SymbolSet.union (SymbolSet.remove "eps" (computeFirstSet first t)) (SMap.find h follow)) (SMap.find nt follow)) follow) nt t
  else updateFollowSet first (SMap.add h (SymbolSet.union (SMap.find h follow) (computeFirstSet first t)) follow) nt t

  else updateFollowSet first follow nt t
    
               
;;
(** 
let recurseFollowSetsHelper rules first follow followFunc = 
match rules with
  |[] -> follow
  |h::t -> match h with (*this will get essentially the start symbol*)
      (*break it apart using the tuples deconstructor*)
      (*this will call followsets helper on the NEXT token in the grammar's list*)
        |(lhs, rhs) -> recurseFollowSetsHelper t first (followFunc first follow lhs rhs) followFunc
      ;;
*)
let recurseFollowSets (g : grammar) (first : symbolMap) (follow : symbolMap) followFunc : symbolMap = 
  let rec recurseFollowHelper follow followFunc rule_list = match rule_list with 
  (*if nothing is inside hte rule list, return the plain follow set*)
  | [] -> follow  (*breaking apart this tuple will let us point to the rhs list of symbols*)
  | r1::rs -> match r1 with (lhs,rhs) -> 
                            let follow' = (followFunc first follow lhs rhs)
                                            in recurseFollowHelper follow' followFunc rs                                            
  (* (snd g) immediately returns the grammar on the right hand side!*)
  in let rule_list = (snd g) in recurseFollowHelper follow followFunc rule_list 
;;

let rec getFollowSets (g : grammar) (first : symbolMap) (follow : symbolMap) followFunc : symbolMap =
  if (SMap.equal (SymbolSet.equal) (recurseFollowSets g first follow updateFollowSet) follow)
        then
          follow
        else
          getFollowSets g first (recurseFollowSets g first follow updateFollowSet) (updateFollowSet)
;;

let rec predictHelper rule_list first follow firstFunc predict = 
match rule_list with (*predict is our accumulator*)
|[] -> predict
|h::t -> match h with (lhs,rhs) -> if SymbolSet.mem "eps" (firstFunc first rhs) then
 (*will check if the first symbol has epsilon)*)
 (*recursively call the helper, finding the first set - epsilon unionined with the follow set of the lhs*)
 predictHelper t first follow firstFunc ((h, (SymbolSet.union (SymbolSet.remove "eps" (firstFunc first rhs)) (SMap.find lhs follow)))::predict)
else
(*if there isnt an epsilon, we just return the symbol's first set*)
predictHelper t first follow firstFunc((h, (firstFunc first rhs))::predict)

;;

let rec getPredictSets (g : grammar) (first : symbolMap) (follow : symbolMap) firstFunc : ((string * string list) * SymbolSet.t) list =
  List.rev (predictHelper (snd g) first follow firstFunc []) ;;
;;



let rec ruleFinder nt predict s =
match predict with 
(*if its an empty predict set, just a failed string*)
|[] -> ["fail"]
|h::t -> match h with 
(*break the tuple again*)
  |(rule, pred) -> match rule with 
                |(lhs, rhs) -> if nt = lhs then
                                      (*check if the rule is in the predict set*)
                                        if SymbolSet.mem s pred then rhs 
                                        (*iterate till oyu fnd the rule*)
                                        else ruleFinder nt t s
                                  (*regardless, make a recursive call*)
                                else ruleFinder nt t s
;;

let rec matcher rule input ifs predict =
match input with
|["fail"] -> ["fail"]
(*if this is a failure string, just return a failure one*)
|[] -> (match rule with
    (*same thing here*)
    |[] -> []
    (*another failure case*)
    |l::r -> if (ruleFinder l predict "eof") = ["fail"]  then ["fail"]  else [])
|ab::cd -> match rule with
  |[] -> input
  (*split based on the list*)
  |nt::rest -> if (SMap.mem nt ifs) then matcher rest (matcher (ruleFinder nt predict ab) input ifs predict) ifs predict
  else match rule with
        |h::t -> if h = ab then
        (*if it aint there, failure*)
          matcher t cd ifs predict else ["fail"]
;;



(*non terminal is the start symbol of the grammar*)
(*sentence is just the grammar*)
(*implement a stack in the form of a list*)
let rec deriveHelper nt predict input ifs: bool = 
(*if (first symbol in grammar is a terminal) then match first symbol in input with first symbol in sentence*)
(*terminals: eps or []*) 
match input with 
(*if input is invalid, just return a failure*)
|[] -> if (ruleFinder nt predict "eof") = ["fail"] then false else true
|h::t -> if (matcher (ruleFinder nt predict h) input ifs predict) = [] 
then true 
else false 
;;



let tryDerive (g : grammar) (inputStr : string list) : bool =
  let first = getFirstSets g (getInitFirstSets g) computeFirstSet in
  let ifs = getInitFirstSets g in

  let follow = getFollowSets g first (getInitFollowSets g) updateFollowSet in
  let predictSet = getPredictSets g first follow computeFirstSet in
  (*getstartsymbol is the first NONTERMINAL*)
  deriveHelper (getStartSymbol g) predictSet inputStr ifs
;;

let tryDeriveTree (g : grammar) (inputStr : string list) : parseTree =
  (* YOUR CODE GOES HERE *)
Terminal "empty";;

let genParser g = tryDerive g;;
let genTreeParser g = tryDeriveTree g;;
