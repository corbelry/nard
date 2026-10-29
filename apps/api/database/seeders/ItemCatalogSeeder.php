<?php

namespace Database\Seeders;

use App\Models\Item;
use Illuminate\Database\Seeder;

/**
 * Built-in cosmetics: the six board sets of the design
 * (apps/client/lib/theme/board_theme.dart, BoardTheme.all) plus default
 * checkers, dice and cube. Prices are placeholders until the owner confirms
 * them (docs/QUESTIONS.md). Idempotent.
 */
class ItemCatalogSeeder extends Seeder
{
    public function run(): void
    {
        $boards = [
            // id, name, rarity, coins, gems, colors [pointA, pointB, field, frame, numberColor]
            ['walnut', 'Classic Walnut', 'common', null, null, ['#FF1A0E07', '#FFE3D3B4', '#FFB4824D', '#FF5D3720', '#8CF3EBDD']],
            ['minimal_pro', 'Minimal Pro', 'common', 2000, null, ['#FFE9E6DF', '#FF5C6068', '#FF2A2D32', '#FF1F2125', '#B3ECE7DE']],
            ['carpet_heritage', 'Carpet Heritage', 'rare', 6000, null, ['#FF1F2B5C', '#FFE6D6B4', '#FF7B1C22', '#FF3C1C12', '#8CF3EBDD']],
            ['baku_night', 'Baku Night', 'epic', null, 300, ['#FFB08A35', '#FF2C3352', '#FF1E2230', '#FF171A23', '#8CE8C468']],
            ['caspian', 'Caspian', 'seasonal', null, 400, ['#FFDDD0B8', '#FF08242C', '#FF16546A', '#FF0C323C', '#8CECE3D1']],
            ['marble_royale', 'Marble Royale', 'legendary', null, 800, ['#FF1C1C20', '#FFCFAE5C', '#FFE8E4DD', '#FF1A1A1E', '#B3E8C468']],
        ];
        foreach ($boards as $i => [$id, $name, $rarity, $coins, $gems, $c]) {
            Item::query()->updateOrCreate(['id' => "board.$id"], [
                'category' => 'board',
                'rarity' => $rarity,
                'price_coins' => $coins,
                'price_gems' => $gems,
                'is_default' => $id === 'walnut',
                'available' => true,
                'sort' => $i,
                'data' => [
                    'name' => $name,
                    'theme' => $id,
                    'pointA' => $c[0],
                    'pointB' => $c[1],
                    'field' => $c[2],
                    'frame' => $c[3],
                    'numberColor' => $c[4],
                ],
            ]);
        }
        $defaults = [
            ['checkers.classic', 'checkers', ['name' => 'Classic', 'light' => '#FFEFE4CF', 'dark' => '#FF2B2724']],
            ['dice.ivory', 'dice', ['name' => 'Ivory', 'face' => '#FFFFFAF0', 'pip' => '#FF0D0806']],
            ['cube.classic', 'cube', ['name' => 'Classic', 'face' => '#FFFBF5E8', 'ink' => '#FF2B1D14']],
        ];
        // Titles are earned through achievements (config/progression.php).
        foreach (['regular', 'veteran', 'mars_master', 'contender'] as $i => $title) {
            $defaults[] = ["title.$title", 'title', ['name' => $title]];
        }
        foreach ($defaults as $i => [$id, $category, $data]) {
            Item::query()->updateOrCreate(['id' => $id], [
                'category' => $category,
                'rarity' => 'common',
                'is_default' => $category !== 'title',
                'available' => true,
                'sort' => $i,
                'data' => $data,
            ]);
        }
    }
}
