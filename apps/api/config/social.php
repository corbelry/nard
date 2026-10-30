<?php

return [
    'max_friends' => 200,
    // Online if seen within this many seconds.
    'online_window' => 120,
    // Design 14.2 (social.md): six reasons incl. deliberately leaving games.
    'report_reasons' => ['cheating', 'abuse', 'name', 'stalling', 'leaving', 'other'],
    // Reports per reporter per day.
    'reports_per_day' => 10,
];
