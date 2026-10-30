<?php

namespace Tests\Unit;

use App\Services\PuzzleService;
use PHPUnit\Framework\TestCase;

class PuzzleBoardTest extends TestCase
{
    public function test_boards_compare_by_position_not_by_key_order_or_type(): void
    {
        $stored = ['white' => [14 => 2, 8 => 4], 'black' => [20 => 2]];
        $sent = ['white' => ['8' => 4, '14' => 2, '3' => 0], 'black' => ['20' => 2]];
        $this->assertSame(PuzzleService::normalize($stored), PuzzleService::normalize($sent));
        $this->assertNotSame(PuzzleService::normalize($stored), PuzzleService::normalize(['white' => [14 => 1, 13 => 1, 8 => 4], 'black' => [20 => 2]]));
    }

    public function test_malformed_boards_are_rejected(): void
    {
        $this->assertNull(PuzzleService::normalize(['white' => []]));
        $this->assertNull(PuzzleService::normalize(['white' => [0 => 1], 'black' => []]));
        $this->assertNull(PuzzleService::normalize(['white' => [26 => 1], 'black' => []]));
        $this->assertNull(PuzzleService::normalize(['white' => [5 => '2'], 'black' => []]));
        $this->assertNull(PuzzleService::normalize(['white' => [5 => 8, 6 => 8], 'black' => []]));
        $this->assertNull(PuzzleService::normalize(['white' => ['x' => 1], 'black' => []]));
        $this->assertSame(['white' => [25 => 1], 'black' => []], PuzzleService::normalize(['white' => [25 => 1], 'black' => []]));
    }
}
