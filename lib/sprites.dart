import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'board.dart';

// Scroll-O-Sprites @ https://imgur.com/a/uHx4k
// 360x1422

//var monochrome = Colors.white;

class SpritePainter extends CustomPainter {
  SpritePainter({Cell? this.cell});

  Cell? cell;
  ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    ui.Image? img = SpriteSheet.instance().image;
    if (img == null) {
      return;
    }

    image = img;

    canvas.save();

    final Paint paint = Paint()
      ..colorFilter =
          ColorFilter.mode(cell?.color ?? Colors.white, BlendMode.srcATop);

    int sprite = cell?.sprite ?? 0;
    double sy = (sprite / 20).floor().toDouble();
    double sx = sprite - (sy * 20);
    Offset src = Offset(sx * 18, sy * 18);

    Size sz = SpriteSheet.instance().size;
    canvas.drawImageRect(img, src & Size(16, 16),
        Offset(-sz.width / 2, -sz.height / 2) & sz, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return image == null;
  }
}

class Sprite extends StatelessWidget {
  Sprite({Key? key, Cell? this.cell}) : super(key: key);

  Cell? cell;

  @override
  Widget build(BuildContext context) {
    BoardData board = Provider.of<BoardData>(context);
//return Text(cell?.data ?? '',
//  style: TextStyle(color: cell?.color, fontSize: 16));
    if (board.hasRip || cell?.sprite == 0) {
      return Text(cell?.data ?? '',
          style: TextStyle(color: cell?.color, fontSize: 20));
//      return SizedBox(width: 8, height: 16, child: Text(cell?.data ?? ''));
    }
//    if (board.isDarkTheme)
//	monochrome = Colors.white;
//    else
//	monochrome = Colors.black;
    return CustomPaint(painter: SpritePainter(cell: cell));
  }
}

class SpriteSheet {
  Map<String, int> tilesetMap = {};
  Map<String, Color> colorMap = {};
  List<int> monstTile = [];
  List<Color> monstStyle = [];

  ui.Image? image;
  Size size = const Size(32, 32);

  static SpriteSheet? theSprites;
  static SpriteSheet instance() {
    if (theSprites == null) {
      theSprites = SpriteSheet();
      theSprites?.initialize();
    }
    return theSprites ?? SpriteSheet();
  }

  // load the image async and then draw with `canvas.drawImage(image, Offset.zero, Paint());`
  Future<ui.Image> loadImageAsset(String assetName) async {
    final data = await rootBundle.load(assetName);
    return decodeImageFromList(data.buffer.asUint8List());
  }

  void initialize() async {

    tilesetMap['.'] = 525; // floor
    tilesetMap['#'] = 526; // floor path
    tilesetMap['-'] = 562; //522; // wall
    tilesetMap['|'] = 563; //522; // wall

    // modify!
    tilesetMap['0'] = 565; // corner wall
    tilesetMap['1'] = 566; // corner wall
    tilesetMap['2'] = 567; // corner wall
    tilesetMap['3'] = 568; // corner wall
    tilesetMap['4'] = 911; // bow
    tilesetMap['5'] = 912; // arrows(darts)
    tilesetMap['6'] = 908; // mace
    tilesetMap['7'] = 756; // rock
    tilesetMap['8'] = 905; // spear

    tilesetMap['+'] = 534; // door
    tilesetMap['['] = 626; // poison pool
    tilesetMap['"'] = 627; // shimmering pool
    tilesetMap['%'] = 532; // staircase

    tilesetMap[':'] = 822; // food
    tilesetMap['!'] = 845; // potion
    tilesetMap[']'] = 927; // armor // 913-helmet
    tilesetMap[')'] = 903; // weapon
    tilesetMap['('] = 689; // monster lair
    tilesetMap['/'] = 983; // wand or staff
    tilesetMap['='] = 929; // ring
    tilesetMap['*'] = 755; // gold
    tilesetMap['?'] = 988; // scroll
    tilesetMap['^'] = 690; // trading post
    tilesetMap[';'] = 626; // rust trap
    tilesetMap['>'] = 622; // trap door
    tilesetMap['{'] = 622; // arrow trap
    tilesetMap['\$'] = 1124; // sleep trap
    tilesetMap['}'] = 624; // bear trap
    tilesetMap['~'] = 633; // teleport trap
    tilesetMap['`'] = 622; // dart trap
    tilesetMap['\\'] = 632; // maze trap
    tilesetMap['<'] = 1114; // fire trap
    tilesetMap[','] = 930; // amulet

    tilesetMap['@'] = 124; // player
    tilesetMap['_'] = 124; // invisible player

    // monsters
    int nmonst = 407;

    List<Color> Styles = [
	Colors.white,
	//monochrome,
	Colors.red,
	Colors.green,
	Colors.blue,
	Colors.yellow,
	Colors.orange,
	Colors.purple,
    ];

    // set all monsters to default tile and colors
    for (int i = 0; i < nmonst; i++) {
	monstTile.add(465);
	monstStyle.add(Styles[i % 7]);
    }
    // change tiles for specific monsters
    monstTile[1]   = 283; // bat
    monstTile[2]   = 344; // xvart
    monstTile[3]   = 282; // giant rat
    monstTile[4]   = 289; // jackal
    monstTile[5]   = 284; // snake
    monstTile[9]   = 130; // halfling
    monstTile[11]  = 344; // orc
    monstTile[12]  = 284; // larva
    monstTile[13]  = 404; // skeleton
    monstTile[19]  = 344; // baboon
    monstTile[20]  = 285; // fire beetle
    monstTile[22]  = 285; // giant ant
    monstTile[24]  = 402; // zombie
    monstTile[29]  = 291; // black bear
    monstTile[31]  = 826; // floating eye
    monstTile[32]  = 130; // brownie
    monstTile[37]  = 285; // giant beetle
    monstTile[38]  = 285; // bomadier beetle
    monstTile[40]  = 294; // wild camel
    monstTile[41]  = 289; // wolf
    monstTile[44]  = 346; // axe beak
    monstTile[46]  = 284; // giant centipede
    monstTile[47]  = 294; // pegasus
    monstTile[51]  = 284; // crocodile
    monstTile[52]  = 294; // hipogriff
    monstTile[53]  = 289; // giant goat
    monstTile[54]  = 282; // wererat
    monstTile[56]  = 291; // brown bear
    monstTile[57]  = 402; // ghoul
    monstTile[58]  = 289; // giant hyena
    monstTile[59]  = 685; // huorn
    //monstTile[65] = 465; // leprechaun
    monstTile[67]  = 294; // centaur
    monstTile[68]  = 293; // pseudo dragon
    monstTile[69]  = 293; // very young dragon
    monstTile[70]  = 283; // batarang
    monstTile[73]  = 290; // mountain lion
    monstTile[75]  = 292; // giant lizard
    monstTile[119]  = 292; // subterranean lizard
    monstTile[163]  = 292; // minotaur lizard
    monstTile[195]  = 292; // fire lizard
    monstTile[76]  = 346; // harpy
    monstTile[78]  = 290; // leopard
    monstTile[79]  = 132; // nymph
    monstTile[83]  = 463; // violet fungi
    monstTile[85]  = 346; // giant eagle
    monstTile[86]  = 346; // peryton
    monstTile[88]  = 346; // giant owl
    monstTile[90]  = 289; // blink dog
    monstTile[94]  = 290; // jaguar
    monstTile[100] = 463; // grey ooze
    monstTile[103] = 289; // hell hound
    monstTile[105] = 289; // winter wolf
    monstTile[101] = 293; // psuedo-dragon
    monstTile[107] = 290; // lion
    monstTile[121] = 293; // plateosaurus
    monstTile[128] = 346; // griffin
    monstTile[131] = 685; // entwife
    monstTile[134] = 290; // giant lynx
    monstTile[135] = 293; // young dragon
    monstTile[136] = 293; // ceratosaurus
    monstTile[144] = 685; // ent
    monstTile[148] = 683; // archer bush
    monstTile[149] = 463; // green slime
    monstTile[150] = 290; // blink saber tooth tiger
    monstTile[152] = 285; // stag beetle
    monstTile[155] = 289; // jackalwere
    monstTile[156] = 291; // were bear
    monstTile[158] = 293; // ankylosaurus
    monstTile[161] = 290; // spotted lion
    monstTile[162] = 285; // killer bee
    monstTile[165] = 292; // teratosaurus
    monstTile[170] = 293; // wyvern
    monstTile[174] = 291; // polar bear
    monstTile[176] = 293; // adult dragon
    monstTile[182] = 292; // anatosaurus
    monstTile[186] = 291; // cave bear
    monstTile[187] = 292; // elasmosaurus
    monstTile[188] = 284; // electric eel
    monstTile[191] = 292; // megalosaurus
    monstTile[192] = 292; // lambeosaurus
    monstTile[193] = 293; // dragonne
    monstTile[196] = 293; // paleoscincus
    monstTile[207] = 291; // heffalump
    monstTile[208] = 291; // elephant
    monstTile[221] = 292; // gorgosaurus
    monstTile[233] = 292; // styracosaurus
    monstTile[236] = 291; // mastodon
    monstTile[238] = 286; // giant scorpion
    monstTile[241] = 463; // gelatinous blue horror
    monstTile[248] = 291; // kodiak bear
    monstTile[249] = 293; // very old dragon
    monstTile[255] = 292; // allosaurus
    monstTile[275] = 292; // stegosaurus
    monstTile[294] = 292; // camarasaurus
    monstTile[295] = 292; // triceratops
    monstTile[297] = 292; // baluchitherium
    monstTile[309] = 292; // diplodocus
    monstTile[310] = 292; // brontosaurus
    monstTile[315] = 292; // cetiosaurus
    monstTile[316] = 292; // brachiosaurus
    monstTile[318] = 292; // tyranosaurus rex
    monstTile[327] = 346; // falcon
    monstTile[333] = 293; // ancient brass dragon
    monstTile[334] = 293; // ancient chrome dragon
    monstTile[335] = 293; // ancient crystal dragon
    monstTile[336] = 293; // ancient white dragon
    monstTile[337] = 293; // ancient black dragon
    monstTile[338] = 293; // ancient copper dragon
    monstTile[339] = 293; // ancient green dragon
    monstTile[340] = 293; // ancient bronze dragon
    monstTile[341] = 293; // ancient blue dragon
    monstTile[342] = 293; // ancient silver dragon
    monstTile[344] = 293; // ancient red dragon
    monstTile[345] = 293; // ancient gold dragon
    monstTile[346] = 293; // ancient night dragon
    monstTile[347] = 293; // ancient electrum dragon
    monstTile[352] = 144; // valkyrie
    monstTile[353] = 165; // evil sorceress
    monstTile[353] = 166; // evil sorcerer
    monstTile[361] = 293; // chromatic dragon
    monstTile[369] = 293; // platinum dragon
    monstTile[404] = 133; // quartermaster
    monstTile[406] = 133; // shopkeeper

    // change colors for specific monsters
    monstStyle[1]  = Colors.grey; // bat
    monstStyle[2]  = Colors.blue; // xvart
    monstStyle[3]  = Colors.blueGrey; // giant rat
    monstStyle[4]  = Colors.brown; // jackal
    monstStyle[13] = Colors.grey.shade100; // skeleton
    monstStyle[20] = Colors.yellow; // fire beetle
    monstStyle[29]  = Colors.grey.shade700; // black bear
    monstStyle[56]  = Colors.brown; // brown bear
    monstStyle[65]  = Colors.green; // leprechaun
    monstStyle[83]  = Colors.purple; // violet fungi
    monstStyle[100] = Colors.grey; // gray ooze
    monstStyle[105] = Colors.grey.shade200; // winter wolf
    monstStyle[149] = Colors.green; // green slime
    monstStyle[155] = Colors.brown; // jackalwere
    monstStyle[174]  = Colors.grey.shade200; // polar bear
    monstStyle[186]  = Colors.brown; // cave bear
    monstStyle[241]  = Colors.blue; // gelatinous blue horror
    monstStyle[248]  = Colors.grey.shade200; // kodiak bear
    monstStyle[333]  = Colors.amber; // ancient brass dragon
    monstStyle[334]  = Colors.grey.shade100; // ancient chrome dragon
    monstStyle[335]  = Colors.blueGrey.shade100; // ancient crystal dragon
    monstStyle[336]  = Colors.white; // ancient white dragon
    monstStyle[337]  = Colors.grey.shade800; // ancient black dragon
    monstStyle[338]  = Colors.amber; // ancient copper dragon
    monstStyle[339]  = Colors.green; // ancient green dragon
    monstStyle[340]  = Colors.amber; // ancient bronze dragon
    monstStyle[341]  = Colors.blue; // ancient blue dragon
    monstStyle[342]  = Colors.grey.shade100; // ancient silver dragon
    monstStyle[344]  = Colors.red; // ancient red dragon
    monstStyle[345]  = Colors.yellow; // ancient gold dragon
    monstStyle[346]  = Colors.grey.shade800; // ancient night dragon
    monstStyle[347]  = Colors.yellow.shade200; // ancient electrum dragon
    monstStyle[361]  = Colors.amber.shade700; // chromatic dragon
    monstStyle[369]  = Colors.grey.shade200; // platinum dragon

    // color map
    colorMap['.'] = const Color.fromRGBO(0x40, 0x40, 0x40, 1);
    colorMap['#'] = const Color.fromRGBO(0x60, 0x40, 0x00, 1);

    colorMap['*'] = Colors.yellow;

    colorMap[')'] = Colors.purple;
    colorMap[']'] = Colors.purple;
    colorMap['4'] = Colors.purple;
    colorMap['5'] = Colors.purple;
    colorMap['6'] = Colors.purple;
    colorMap['8'] = Colors.purple;

    colorMap['?'] = Colors.purple;
    colorMap['!'] = Colors.purple;
    colorMap['/'] = Colors.purple;
    colorMap[':'] = Colors.purple;
    colorMap['\$'] = Colors.purple;
    colorMap[','] = Colors.yellow; // artifact
    colorMap[';'] = Colors.red; // rust trap
    colorMap['{'] = Colors.yellow; // arrow trap
    colorMap['`'] = Colors.yellow; // dart trap
    colorMap['<'] = Colors.yellow; // fire trap
    colorMap['['] = Colors.yellow; // poison pool

    colorMap['^'] = const Color.fromRGBO(0x50, 0xff, 0x55, 1);
    colorMap['%'] = const Color.fromRGBO(0x50, 0xff, 0x55, 1);

    colorMap['+'] = Colors.orange;
    colorMap['-'] = const Color.fromRGBO(0x0, 0xff, 0xff, 1);
    colorMap['|'] = colorMap['-'] ?? Colors.white;
    colorMap['0'] = colorMap['-'] ?? Colors.white;
    colorMap['1'] = colorMap['-'] ?? Colors.white;
    colorMap['2'] = colorMap['-'] ?? Colors.white;
    colorMap['3'] = colorMap['-'] ?? Colors.white;

    colorMap['@'] = const Color.fromRGBO(0xff, 0xff, 0xaa, 1);
    colorMap['_'] = Colors.grey;

    image = await loadImageAsset('assets/Scroll-o-Sprites.png');
  }
}
