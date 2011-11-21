import Char
import List
import Maybe

to_number :: Char  -> Int
to_number c = (fromEnum c) - (fromEnum 'A') + 1

from_number :: Int -> Char
from_number n = (toEnum (n - 1 + fromEnum 'A'))

to_numbers :: String -> [Int]
to_numbers s = map to_number s

cleanse :: String -> String
cleanse c = (map toUpper) ((filter isAlpha) c)

pad :: Int -> Char -> String -> String
pad n c s | length s < n = s ++ (replicate (n-length s) c)
pad n c s = s

maybe_split :: String -> Maybe(String,String)
maybe_split [] = Nothing
maybe_split s | w == "" = Just (pad 5 'X' s,w)
              | True = Just (take 5 s, w)
              where w = drop 5 s

quintets :: String -> [String]
quintets s = (unfoldr maybe_split) s

data Suit = Clubs | Diamonds | Hearts | Spades | A | B
            deriving (Enum, Show, Bounded, Eq)

show_suit :: Suit -> String
show_suit s = (take 1) (show s)

data Face = Ace | Two | Three | Four | Five | Six | Seven 
          | Eight | Nine | Ten | Jack | Queen | King | Joker
            deriving (Enum, Show, Bounded, Eq)
                     
show_face :: Face -> String
show_face f = [head (drop (fromEnum f) "A23456789TJQK$")] 

data Card = Cd Suit Face
          deriving Eq

suit :: Card -> Suit
suit (Cd s _) = s

face :: Card -> Face
face (Cd _ f) = f

instance Enum Card where
    toEnum 53 = (Cd B Joker)
    toEnum 52 = (Cd A Joker)
    toEnum n = let  d = n `divMod` 13
               in Cd (toEnum (fst d)) (toEnum (snd d))
    fromEnum (Cd B Joker) = 53
    fromEnum (Cd A Joker) = 52
    fromEnum c = 13* fromEnum(suit c) + fromEnum(face c)

instance Show Card where
    show c = (show_face (face c)) ++ (show_suit (suit c))

value :: Card -> Int
value (Cd B Joker) = 53
value c = fromEnum c + 1

drop_tail :: [a] -> [a]
drop_tail l = reverse (drop 1 (reverse l))

split_on_elem :: Eq a => a -> [a] -> ([a],[a])
split_on_elem x l | x == head l = ([],drop 1 l)
split_on_elem x l | x == head (reverse l) = (drop_tail l, [])
split_on_elem x l | elemIndex x l == Nothing = error "Can't split a list on an element that isn't present."
split_on_elem x l = let y = fromJust(elemIndex x l)
                    in (take y l, drop (y+1) l)

swap_down :: Card -> [Card] -> [Card]
swap_down x deck | (fst halves) == [] = (head (snd halves)):(x:(drop 1 (snd halves)))
                  | (snd halves) == [] = (head (fst halves)):x:(drop 1 (fst halves))
                  | True = (fst halves) ++ ((head (snd halves)):x:(drop 1 (snd halves)))
    where halves = split_on_elem x deck
                            
move_a :: [Card] -> [Card]
move_a deck = swap_down (Cd A Joker) deck

move_b :: [Card] -> [Card]
move_b deck = swap_down (Cd B Joker) (swap_down (Cd B Joker) deck)

from_m_to_n :: Int -> Int -> [a] -> [a]
from_m_to_n m n l | m < n = take (n-m-1) (drop (m+1) l)
                  | n < m = take (m-n-1) (drop (n+1) l)
               
triple_cut :: Card -> Card -> [Card] -> [Card]
triple_cut x y deck | slot_x < slot_y = (snd (split_y)) ++ (x:(from_m_to_n slot_x slot_y deck)) ++ (y:(fst split_x))
                    | slot_x > slot_y = (snd (split_x)) ++ (y:(from_m_to_n slot_y slot_x deck)) ++ (x:(fst split_y))
                    where slot_x = fromJust(elemIndex x deck)
                          slot_y = fromJust(elemIndex y deck)
                          split_x = split_on_elem x deck
                          split_y = split_on_elem y deck
                 
triple_cut_a_b :: [Card] -> [Card]
triple_cut_a_b deck = triple_cut (Cd A Joker) (Cd B Joker) deck

count_cut :: [Card] -> [Card]
count_cut deck = (drop_tail (drop val deck)) ++ (take val deck) ++ [bottom_card]
               where bottom_card = head (reverse deck)
                     val = value (bottom_card)

evaluate :: [Card] -> Int
evaluate deck = value (head (drop (value(head(deck))) deck))

compute :: [Card] -> (Int,[Card])
compute deck | val == 53 = compute (x)
             | True = ((val `mod` 26), x)
             where x = count_cut ( triple_cut_a_b ( move_b ( move_a ( deck ))))
                   val = evaluate x

encode :: String -> String
encode s = encode_ (concat (quintets (cleanse s))) [(Cd Clubs Ace) .. (Cd B Joker)]

encode_ :: String -> [Card] -> String
encode_ [] _ = []
encode_ (s:ss) deck = let c = compute(deck)
                        in (from_number(wrap_zero ((fst c + (to_number s)) `mod` 26))):(encode_ ss (snd c))

decode :: String -> String
decode s = decode_ s [(Cd Clubs Ace) .. (Cd B Joker)]

decode_ :: String -> [Card] -> String
decode_ [] _ = []
decode_ (s:ss) deck = let c = compute(deck)
                      in (from_number(wrap_zero ((26 + (to_number s) - fst c) `mod` 26))):(decode_ ss (snd c))

wrap_zero :: Int -> Int
wrap_zero 0 = 26
wrap_zero x = x