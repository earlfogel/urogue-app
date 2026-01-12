cmake_minimum_required(VERSION 3.10)
project(api LANGUAGES CXX C)

set (CMAKE_CXX_STANDARD 11)

add_library(pdcurses
  STATIC
  ./PDCurses-3.4/pdcurses/addch.c
  ./PDCurses-3.4/pdcurses/addchstr.c
  ./PDCurses-3.4/pdcurses/addstr.c
  ./PDCurses-3.4/pdcurses/attr.c
  ./PDCurses-3.4/pdcurses/beep.c
  ./PDCurses-3.4/pdcurses/bkgd.c
  ./PDCurses-3.4/pdcurses/border.c
  ./PDCurses-3.4/pdcurses/clear.c
  ./PDCurses-3.4/pdcurses/color.c
  ./PDCurses-3.4/pdcurses/debug.c
  ./PDCurses-3.4/pdcurses/delch.c
  ./PDCurses-3.4/pdcurses/deleteln.c
  ./PDCurses-3.4/pdcurses/deprec.c
  ./PDCurses-3.4/pdcurses/getch.c
  ./PDCurses-3.4/pdcurses/getstr.c
  ./PDCurses-3.4/pdcurses/getyx.c
  ./PDCurses-3.4/pdcurses/inch.c
  ./PDCurses-3.4/pdcurses/inchstr.c
  ./PDCurses-3.4/pdcurses/initscr.c
  ./PDCurses-3.4/pdcurses/inopts.c
  ./PDCurses-3.4/pdcurses/insch.c
  ./PDCurses-3.4/pdcurses/insstr.c
  ./PDCurses-3.4/pdcurses/instr.c
  ./PDCurses-3.4/pdcurses/kernel.c
  ./PDCurses-3.4/pdcurses/keyname.c
  ./PDCurses-3.4/pdcurses/mouse.c
  ./PDCurses-3.4/pdcurses/move.c
  ./PDCurses-3.4/pdcurses/outopts.c
  ./PDCurses-3.4/pdcurses/overlay.c
  ./PDCurses-3.4/pdcurses/pad.c
  ./PDCurses-3.4/pdcurses/panel.c
  ./PDCurses-3.4/pdcurses/printw.c
  ./PDCurses-3.4/pdcurses/refresh.c
  ./PDCurses-3.4/pdcurses/scanw.c
  ./PDCurses-3.4/pdcurses/scr_dump.c
  ./PDCurses-3.4/pdcurses/scroll.c
  ./PDCurses-3.4/pdcurses/slk.c
  ./PDCurses-3.4/pdcurses/termattr.c
  ./PDCurses-3.4/pdcurses/terminfo.c
  ./PDCurses-3.4/pdcurses/touch.c
  ./PDCurses-3.4/pdcurses/util.c
  ./PDCurses-3.4/pdcurses/window.c
  ./PDCurses-3.4/impl/pdc_impl.c
)

target_include_directories(pdcurses 
    PRIVATE
    ./PDCurses-3.4/impl
    ./PDCurses-3.4/
)

add_definitions(-fPIC -DFLUTTER)
add_library(rogue
  STATIC
  ./urogue/armor.c
  ./urogue/artifact.c
  ./urogue/chase.c
  ./urogue/command.c
  ./urogue/daemon.c
  ./urogue/daemons.c
  ./urogue/encumb.c
  ./urogue/fight.c
  ./urogue/get_play.c
  ./urogue/init.c
  ./urogue/io.c
  ./urogue/list.c
  ./urogue/maze.c
  ./urogue/misc.c
  ./urogue/monsdata.c
  ./urogue/monsters.c
  ./urogue/move.c
  ./urogue/new_level.c
  ./urogue/options.c
  ./urogue/pack.c
  ./urogue/passages.c
  ./urogue/player.c
  ./urogue/potions.c
  ./urogue/rings.c
  ./urogue/rip.c
  ./urogue/rogue.c
  ./urogue/rogue_main.c
  ./urogue/rooms.c
  ./urogue/save.c
  ./urogue/scrolls.c
  ./urogue/state.c
  ./urogue/sticks.c
  ./urogue/sys_dep.c
  ./urogue/things.c
  ./urogue/trader.c
  ./urogue/tunable.c
  ./urogue/vers.c
  ./urogue/weapons.c
  ./urogue/wizard.c
)

target_include_directories(rogue 
    PRIVATE
    ./PDCurses-3.4/
    ./urogue/
)

#target_link_libraries(rogue INTERFACE pdcurses)

add_library(api
  SHARED
  ./api.cpp
  exports.def
)

target_include_directories(api 
    PRIVATE
    ./PDCurses-3.4/
    ./urogue/
)

target_link_libraries(api PRIVATE rogue pdcurses)
