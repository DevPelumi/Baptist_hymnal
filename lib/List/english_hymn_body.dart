import 'package:flutter/material.dart';

class EnglishHymnBody {
  String hymnContent;
  int hymnTitle;

  EnglishHymnBody({@required this.hymnContent, this.hymnTitle});
}

List<EnglishHymnBody> englishHymnBodyData = [
  EnglishHymnBody(
    hymnTitle: 1,
    hymnContent: '''  
1
Holy, holy, holy! Lord God Almighty!
Early in the morning our song shall rise to thee.
Holy, holy, holy! Merciful and mighty!
God in three Persons, blessed Trinity!
2 
Holy, holy, holy! All the saints adore thee,
casting down their golden crowns around the glassy sea;
cherubim and seraphim falling down before thee,
who wert, and art, and evermore shalt be.
3 
Holy, holy, holy! Though the darkness hide thee,
though the eye of sinful man thy glory may not see,
only thou art holy; there is none beside thee
perfect in pow'r, in love, and purity.
4
Holy, holy, holy! Lord God Almighty!
All thy works shall praise thy name in earth and sky and sea.
Holy, holy, holy! Merciful and mighty!
God in three Persons, blessed Trinity!
''',
  ),
  EnglishHymnBody(hymnTitle: 2, hymnContent: '''
1
Love divine, all love’s excelling,
Joy of heaven, to earth come down,
Fix in us Thy humble dwelling,
All Thy faithful mercies crown:
Jesus, Thou art all compassion,
Pure, unbounded love Thou art;
Visit us with Thy salvation,
Enter every trembling heart.
2
Breathe, O breathe Thy loving Spirit,
Into every troubled breast;
Let us all in Thee inherit,
Let us find Thy promised rest;
Take away the love of sinning,
Alpha and omega be;
End of faith, as it ‘s beginning,
Set our hearts at liberty.
3
Come, almighty to deliver,
Let us all Thy grace receive;
Suddenly return, and never,
Never more Thy temples leave.
Thee we would be always blessing.
Serve Thee as Thy hosts above,
Pray, and praise Thee without ceasing,
Glory in Thy perfect love.
4
Finish, then, Thy new creation:
Pure and spotless let us be;
Let us see Thy great salvation,
Perfectly restored in Thee,
Changed from glory into glory,
Till in heaven we take our place,
Till we cast our crowns before Thee,
Lost in wonder, love, and praise.
  '''),
  EnglishHymnBody(hymnTitle: 3 , hymnContent: '''
  
1.	All creature or our God and King,
Lift up your voice and with us sing 
Alleluia! Alleluia!
Thou burning sun with golden beam, 
Thou silver moon with softer gleam!
O praise Him, O praise Him!
Alleluia! Alleluia! Alleluia! 
2.	Thou rushing wind that art so strong,
Ye clouds that sail in heaven along, 
O praise Him! Alleluia! 
Thou rising morn, in praise rejoice, 
Ye lights of evening, find a voice! 
O Praise Him, O praise Him!
Alleluia! Alleluia! Alleluia!
3.	Dear mother earth, who day by day 
Unfoldest blessings our way, 
O praise Him! Alleluia! 
The flowers and fruits that in thee grow,
Let them His glory also show!
O Praise Him, O praise Him!
Alleluia! Alleluia! Alleluia!
4.	Let all things their Creator bless, And worship Him in humbleness, 
O praise Him! Alleluia!
Praise, praise the Father, praise the Son,
And praise the Spirit, Three in One! 
O Praise Him, O praise Him!
Alleluia! Alleluia! Alleluia!
  
  ''' ),

  EnglishHymnBody(hymnTitle: 4 , hymnContent: '''
  
  1.	Mighty God, while angels bless Thee,
May a mortal lisp Thy name? 
Lord of men, as well as angels, 
Thou art ev’ry creature’s theme 
Lord of ev’ry land and nation.
Ancient of eternal days, Sounded thro’ the wide creation 
Be Thy just and endless praise
2.	For the grandueur of Thy nature, 
Grand beyond a seraph’s thought; 
For the wonders of creation; 
Works with skill and kindness wrought; 
For Thy providence that governs Thro’ Thine empire’s wide domain,
Wings hand angel, guides a sparrow, Blessed be Thy gentle reign. 
3.	But Thy rich, Thy free redemption, Bight, tho’veiled in darkness long;
Thought is poor, and poor expression;
Who can sing that wondrous song? 
Brightness of the Father’s glory, 
Shall Thy praise un-uttered lie?
Break, my tongue, such guilty silence! 
Sing the Lord who came to die. 
4.	From the highest throne of glory
To the cross of deepest woe, 
Thou didst stoop to ransom captives;
Flow my praise, forever flow.
Re-ascend immortal Saviour, 
Leave Thy foot-stool, take thy throne: 
Thence return and reign forever: 
Be the kingdom all thine own!
  ''' )
];