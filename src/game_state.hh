// SPDX-License-Identifier: GPL-2.0-or-later
/*
** This file is part of Prologin2018, a rules library for stechec2.
**
** Copyright (c) 2018 Association Prologin <info@prologin.org>
**
** Prologin2018 is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Prologin2018.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef GAME_STATE_HH
#define GAME_STATE_HH

#include <rules/game-state.hh>
#include <rules/player.hh>

#include <array>
#include <unordered_map>

#include "player_info.hh"
#include "map.hh"

class GameState : public rules::GameState
{
    public:
        GameState(std::istream& map_stream, rules::Players_sptr players);
        rules::GameState* copy() const override;

        void reset_action_points();

        unsigned int opponent(unsigned int player) const;

        void increment_turn();
        unsigned int get_turn() const;

        bool is_finished() const;

        void reset_history(unsigned int player_id);

    private:
        std::unordered_map<unsigned int, PlayerInfo> player_info_;
        std::array<unsigned int, 2> player_ids_;

        std::shared_ptr<const Map> map_;
        unsigned int turn_;
};

#endif /* !GAME_STATE_HH */
