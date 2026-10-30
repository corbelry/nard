<?php

// Practice puzzles (13.x; design notes tournaments.md §12, §17 #48–#54;
// ADR-039). Puzzle rating is separate from the game rating.
return [
    'initial_rating' => 1500,
    // Attempts per puzzle ("Bir cəhd qaldı").
    'max_attempts' => 2,
    // Rating change per attempt number: first-try correct +12, wrong −8
    // (design); the second attempt is worth half (proposal "ilk cəhddə").
    'correct' => [1 => 12, 2 => 6],
    'wrong' => [1 => -8, 2 => -4],
];
