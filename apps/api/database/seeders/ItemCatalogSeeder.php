<?php

namespace Database\Seeders;

use App\Models\Item;
use Illuminate\Database\Seeder;

/**
 * Built-in cosmetics from the design (docs/design-notes/store.md §1.1).
 * A board item carries the whole set look (board, checkers, dice, table)
 * in its `data` (ADR-034); the client renders it without an app update.
 * Prices follow the design and await the owner's confirmation. Idempotent.
 */
class ItemCatalogSeeder extends Seeder
{
    public function run(): void
    {
        foreach ($this->boards() as $sort => $b) {
            Item::query()->updateOrCreate(['id' => 'board.'.$b['id']], [
                'category' => 'board',
                'rarity' => $b['rarity'],
                'price_coins' => $b['coins'] ?? null,
                'price_gems' => $b['gems'] ?? null,
                'is_default' => $b['id'] === 'walnut',
                'available' => true,
                'sort' => $sort,
                'data' => [
                    'theme' => $b['id'],
                    'name' => $b['name'],
                    'description' => $b['description'],
                    // Where the item comes from when it is not for sale.
                    'obtain' => $b['obtain'] ?? ($b['id'] === 'walnut' ? 'default' : 'store'),
                    'look' => $b['look'],
                ],
            ]);
        }
        $defaults = [
            ['checkers.classic', 'checkers', ['name' => ['az' => 'Klassik', 'en' => 'Classic']]],
            ['dice.ivory', 'dice', ['name' => ['az' => 'Fil sümüyü', 'en' => 'Ivory']]],
            ['cube.classic', 'cube', ['name' => ['az' => 'Klassik', 'en' => 'Classic']]],
        ];
        // Titles are earned through achievements (config/progression.php).
        foreach (['regular' => ['Daimi', 'Regular'], 'veteran' => ['Veteran', 'Veteran'], 'mars_master' => ['Mars ustası', 'Mars master'], 'contender' => ['İddiaçı', 'Contender']] as $id => [$az, $en]) {
            $defaults[] = ["title.$id", 'title', ['name' => ['az' => $az, 'en' => $en], 'obtain' => 'achievement']];
        }
        // Tournament titles (config/tournaments.php prizes).
        foreach (['friday_champion' => ['Cümə Çempionu', 'Friday Champion'], 'league_champion' => ['Liqa Çempionu', 'League Champion']] as $id => [$az, $en]) {
            $defaults[] = ["title.$id", 'title', ['name' => ['az' => $az, 'en' => $en], 'obtain' => 'tournament', 'rarity' => 'tournament']];
        }
        foreach ($defaults as $i => [$id, $category, $data]) {
            $rarity = $data['rarity'] ?? 'common';
            $data = array_diff_key($data, ['rarity' => true]);
            Item::query()->updateOrCreate(['id' => $id], [
                'category' => $category,
                'rarity' => $rarity,
                'is_default' => $category !== 'title',
                'available' => true,
                'sort' => $i,
                'data' => $data,
            ]);
        }
    }

    /**
     * Gradients are top → bottom lists of #AARRGGBB.
     *
     * @return array<int, array<string, mixed>>
     */
    private function boards(): array
    {
        $ivory = ['stops' => ['#FFFFFBF2', '#FFEFE4CF', '#FFD4C3A2', '#FFB3A07C'], 'groove' => '#2B6E5532'];
        $onyx = ['stops' => ['#FF5D564F', '#FF2B2724', '#FF151312', '#FF0A0909'], 'groove' => '#0EFFFFFF'];
        $ivoryDie = ['face' => ['#FFFFFAF0', '#FFE4D6B8'], 'pip' => ['#FF3A2A1E', '#FF0D0806']];

        return [
            ['id' => 'walnut', 'rarity' => 'common',
                'name' => ['az' => 'Klassik Qoz', 'en' => 'Classic Walnut'],
                'description' => ['az' => 'Standart. Oyma ceviz, fil sümüyü və qara daşlar, qara xallı ağ zərlər.', 'en' => 'The standard. Carved walnut, ivory and onyx checkers, white dice with black pips.'],
                'look' => ['frame' => ['#FF6E4224', '#FF4B2B16', '#FF5D3720'], 'field' => ['#FFC49159', '#FFA87745'], 'pointA' => ['#FF2E1C10', '#FF1A0E07'], 'pointB' => ['#FFF2E7CF', '#FFD5C29D'], 'tray' => ['#FF2A170C', '#FF1C0F07'], 'numbers' => '#8CF3EBDD', 'grain' => true, 'light' => $ivory, 'dark' => $onyx, 'dice' => $ivoryDie, 'table' => ['#FF3B2819', '#FF1B120C']]],
            ['id' => 'minimal_pro', 'rarity' => 'common', 'coins' => 1500,
                'name' => ['az' => 'Minimal Pro', 'en' => 'Minimal Pro'],
                'description' => ['az' => 'Sadə, düz rənglər. Diqqəti oyuna yönəldir.', 'en' => 'Plain, flat colours that keep the focus on the game.'],
                'look' => ['frame' => ['#FF1F2125', '#FF1F2125'], 'field' => ['#FF2A2D32', '#FF2A2D32'], 'pointA' => ['#FFE9E6DF', '#FFE9E6DF'], 'pointB' => ['#FF5C6068', '#FF5C6068'], 'tray' => ['#FF17181B', '#FF17181B'], 'numbers' => '#B3ECE7DE', 'light' => ['stops' => ['#FFF5F3EE', '#FFF5F3EE'], 'flat' => true], 'dark' => ['stops' => ['#FF111214', '#FF111214'], 'rim' => '#FF4A4D53', 'flat' => true], 'dice' => ['face' => ['#FFF5F3EE', '#FFF5F3EE'], 'pip' => ['#FF111214', '#FF111214'], 'flat' => true], 'table' => ['#FF16181D', '#FF16181D']]],
            ['id' => 'dark', 'rarity' => 'rare', 'coins' => 900,
                'name' => ['az' => 'Gecə Qarağacı', 'en' => 'Night Elm'],
                'description' => ['az' => 'Tünd qarağac, pirinc və tünd qırmızı xanalar.', 'en' => 'Dark elm with brass and deep red points.'],
                'look' => ['frame' => ['#FF3B2617', '#FF22150C', '#FF2E1D11'], 'field' => ['#FF4D3322', '#FF3A2519'], 'pointA' => ['#FFB08B3F', '#FF7D5F24'], 'pointB' => ['#FF7E1B2D', '#FF530E1C'], 'tray' => ['#FF140C07', '#FF0C0704'], 'numbers' => '#80ECE7DE', 'grain' => true, 'light' => $ivory, 'dark' => [...$onyx, 'rim' => '#CCD4AE58'], 'dice' => $ivoryDie, 'table' => ['#FF2E1D11', '#FF0C0704']]],
            ['id' => 'carpet_heritage', 'rarity' => 'rare', 'coins' => 1200,
                'name' => ['az' => 'Xalça İrsi', 'en' => 'Carpet Heritage'],
                'description' => ['az' => 'Xalça naxışlı xanalar, qırmızı/indiqo palitrası, pirinç kənarlı daşlar.', 'en' => 'Carpet-patterned points in red and indigo, brass-rimmed checkers.'],
                'look' => ['frame' => ['#FF4A2418', '#FF2E140C'], 'field' => ['#FF8A2228', '#FF6C171D'], 'pointA' => ['#FF26346E', '#FF18214A'], 'pointB' => ['#FFF1E4C8', '#FFD6C39D'], 'tray' => ['#FF1F0D08', '#FF140804'], 'numbers' => '#8CF3EBDD', 'grain' => true, 'light' => [...$ivory, 'rim' => '#FFB88F3A'], 'dark' => ['stops' => ['#FF4A5A9A', '#FF26346E', '#FF141C40'], 'groove' => '#0FFFFFFF', 'rim' => '#FFC9A24A'], 'dice' => ['face' => ['#FFFFFAF0', '#FFE4D6B8'], 'pip' => ['#FFC2323C', '#FF6C171D']], 'table' => ['#FF3A1416', '#FF140708']]],
            ['id' => 'baku_night', 'rarity' => 'epic', 'gems' => 600,
                'name' => ['az' => 'Bakı Gecəsi', 'en' => 'Baku Night'],
                'description' => ['az' => 'Gecə şəhəri, Flame Towers işıltısı. Qızıl və oniks daşlar, qara zərdə qızıl xal.', 'en' => 'The city at night and the glow of the Flame Towers. Gold and onyx checkers, gold pips on black dice.'],
                'look' => ['frame' => ['#FF1D212C', '#FF11131A'], 'field' => ['#FF232838', '#FF171A26'], 'glow' => '#2EE8783C', 'pointA' => ['#FFD9B560', '#FF8A6A22'], 'pointB' => ['#FF39406A', '#FF20253F'], 'tray' => ['#FF0B0D12', '#FF0B0D12'], 'numbers' => '#8CE8C468', 'light' => ['stops' => ['#FFFFF3C8', '#FFE8C86E', '#FFB08A35', '#FF8A6A22'], 'groove' => '#33785010'], 'dark' => [...$onyx, 'rim' => '#99E8C468'], 'dice' => ['face' => ['#FF2C2C33', '#FF101014'], 'pip' => ['#FFFFF0B8', '#FFC9A24A']], 'table' => ['#FF3A2418', '#FF0D0F16']]],
            ['id' => 'caspian', 'rarity' => 'seasonal', 'obtain' => 'season',
                'name' => ['az' => 'Xəzər', 'en' => 'Caspian'],
                'description' => ['az' => 'Dəniz mavisi, qum rəngli xanalar, sədəf daşlar.', 'en' => 'Sea teal, sand points and mother-of-pearl checkers.'],
                'look' => ['frame' => ['#FF0F3D48', '#FF082731'], 'field' => ['#FF1D6577', '#FF16546A'], 'pointA' => ['#FFECE3D1', '#FFCDBD9F'], 'pointB' => ['#FF0A2C36', '#FF061C23'], 'tray' => ['#FF05161B', '#FF05161B'], 'numbers' => '#8CECE3D1', 'light' => ['stops' => ['#FFFFFFFF', '#FFF1F0F4', '#FFD8D6E0', '#FFB8B6C4'], 'groove' => '#1A787890'], 'dark' => ['stops' => ['#FF3A5566', '#FF142836', '#FF08141C'], 'groove' => '#0FFFFFFF'], 'dice' => ['face' => ['#FFFFF4EE', '#FFECD2C4'], 'pip' => ['#FF1D4A5A', '#FF061C23']], 'table' => ['#FF123844', '#FF051318']]],
            ['id' => 'xatam', 'rarity' => 'epic', 'obtain' => 'tournament',
                'name' => ['az' => 'Şuşa Xatəmi', 'en' => 'Shusha Inlay'],
                'description' => ['az' => 'Xatəm kakmalı çərçivə, qırmızı və sümük rəngli xanalar.', 'en' => 'Xatam-inlaid frame with garnet and bone points.'],
                'look' => ['frame' => ['#FF5C2B17', '#FF3E1C0E', '#FF4C2414'], 'field' => ['#FF9C683D', '#FF835330'], 'inlay' => ['#FFC9A24A', '#FFF3EBDD', '#FF9E1B32', '#FF1C120B'], 'pointA' => ['#FFA8213B', '#FF72111F'], 'pointB' => ['#FFF2E7CF', '#FFD5C29D'], 'tray' => ['#FF24120A', '#FF170A05'], 'numbers' => '#8CF3EBDD', 'grain' => true, 'light' => $ivory, 'dark' => $onyx, 'dice' => $ivoryDie, 'table' => ['#FF3B2819', '#FF1B120C']]],
            ['id' => 'marble_royale', 'rarity' => 'legendary', 'gems' => 1800,
                'name' => ['az' => 'Kral Mərməri', 'en' => 'Marble Royale'],
                'description' => ['az' => 'Ağ və qara mərmər, qızıl kakma, kristal zərlər.', 'en' => 'White and black marble, gold inlay, crystal dice.'],
                'look' => ['frame' => ['#FF2A2A2E', '#FF0F0F12'], 'field' => ['#FFF4F1EC', '#FFDCD7CF'], 'inlay' => ['#FFE9CF82', '#FFA8822F'], 'pointA' => ['#FF2A2A2E', '#FF0F0F12'], 'pointB' => ['#FFE9CF82', '#FFB38A35'], 'tray' => ['#FF141416', '#FF08080A'], 'numbers' => '#B3E8C468', 'light' => ['stops' => ['#FFFFFFFF', '#FFF4F1EC', '#FFDCD7CF', '#FFBDB6AC'], 'rim' => '#FFC9A24A'], 'dark' => ['stops' => ['#FF3A3A40', '#FF1C1C20', '#FF0F0F12', '#FF050507'], 'rim' => '#FFC9A24A'], 'dice' => ['face' => ['#F2EBF5FF', '#BFAAC8E6', '#E6DCEBFA'], 'pip' => ['#FF3A5A8A', '#FF0E1D36']], 'table' => ['#FF2E2A24', '#FF0C0B0A']]],
        ];
    }
}
