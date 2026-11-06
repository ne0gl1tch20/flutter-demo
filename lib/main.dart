import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const FlutterDemoApp());

const ink = Color(0xFF090D18), panel = Color(0xFF151D30), violet = Color(0xFF9B8CFF), mint = Color(0xFF75E0C1);

class FlutterDemoApp extends StatelessWidget {
  const FlutterDemoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Demo', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: ink, colorScheme: ColorScheme.fromSeed(seedColor: violet, brightness: Brightness.dark, surface: panel), useMaterial3: true),
    home: const HomePage(),
  );
}

class Lab {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  const Lab(this.title, this.subtitle, this.icon, this.color, this.page);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final labs = <Lab>[
      Lab('Animation Studio', 'Transitions, springs and motion details', Icons.animation_rounded, violet, const AnimationPage()),
      Lab('Gesture Playground', 'Drag, swipe and interact with touch', Icons.touch_app_rounded, mint, const GesturePage()),
      Lab('UI Showcase', 'Buttons, cards and expressive components', Icons.widgets_rounded, const Color(0xFFFFB86B), const UiPage()),
      Lab('Physics Lab', 'Bouncy motion and playful physics', Icons.bubble_chart_rounded, const Color(0xFF73B7FF), const PhysicsPage()),
      Lab('Custom Graphics', 'Gradients, shapes and CustomPainter', Icons.palette_rounded, const Color(0xFFFF82AD), const GraphicsPage()),
    ];
    return Scaffold(body: SafeArea(child: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(22,22,22,14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width:44,height:44,decoration:BoxDecoration(gradient:const LinearGradient(colors:[violet,mint]),borderRadius:BorderRadius.circular(15)),child:const Icon(Icons.bolt_rounded,color:ink,size:28)),
          const SizedBox(width:12),
          const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('FLUTTER / PLAYGROUND',style:TextStyle(fontSize:10,letterSpacing:2,color:mint,fontWeight:FontWeight.w800)),Text('Made to move.',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900))]),
          const Spacer(),
          IconButton(tooltip:'Secret',onPressed:()=>showDialog(context:context,builder:(_)=>const AlertDialog(title:Text('You found a little secret ✨'),content:Text('Curiosity is a feature. Keep tapping around.'))),icon:const Icon(Icons.auto_awesome_rounded,color:violet)),
        ]),
        const SizedBox(height:30),
        const Text('Explore the details.',style:TextStyle(fontSize:31,height:1.1,fontWeight:FontWeight.w900,letterSpacing:-1)),
        const SizedBox(height:9),
        const Text('A playground for big Flutter ideas. Tap around, try things and see what happens.',style:TextStyle(color:Color(0xFF9AA6C0),height:1.5,fontSize:14)),
        const SizedBox(height:22),
        Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(23),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF302951),Color(0xFF17343B)]),border:Border.all(color:Colors.white12)),child:const Row(children:[
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('FIVE WAYS TO EXPLORE',style:TextStyle(color:mint,fontSize:10,letterSpacing:1.5,fontWeight:FontWeight.w800)),SizedBox(height:8),Text('Small details.\nBig personality.',style:TextStyle(fontSize:22,height:1.15,fontWeight:FontWeight.w800)),SizedBox(height:6),Text('An interactive Flutter showcase',style:TextStyle(color:Color(0xFFB9C4D9),fontSize:12))])),
          Icon(Icons.bubble_chart_rounded,size:62,color:violet),
        ])),
        const SizedBox(height:27),
        const Text('THE LABS',style:TextStyle(fontSize:11,letterSpacing:2,color:Color(0xFF8793AD),fontWeight:FontWeight.w800)),
        const SizedBox(height:12),
      ]))),
      SliverPadding(padding:const EdgeInsets.fromLTRB(18,0,18,28),sliver:SliverList(delegate:SliverChildBuilderDelegate((context,i){
        final lab=labs[i];
        return Padding(padding:const EdgeInsets.only(bottom:11),child:Material(color:panel,borderRadius:BorderRadius.circular(20),clipBehavior:Clip.antiAlias,child:InkWell(onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>lab.page)),child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
          Container(width:49,height:49,decoration:BoxDecoration(color:lab.color.withValues(alpha:.13),borderRadius:BorderRadius.circular(16)),child:Icon(lab.icon,color:lab.color,size:26)),
          const SizedBox(width:14),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(lab.title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),const SizedBox(height:4),Text(lab.subtitle,style:const TextStyle(color:Color(0xFF9AA6C0),fontSize:12))])),
          const Icon(Icons.arrow_forward_ios_rounded,size:15,color:Color(0xFF78849E)),
        ])))));
      },childCount:labs.length))),
      const SliverToBoxAdapter(child:Padding(padding:EdgeInsets.only(bottom:25),child:Center(child:Text('BUILT WITH FLUTTER • MADE FOR CURIOSITY',style:TextStyle(color:Color(0xFF65718B),fontSize:9,letterSpacing:1.4))))),
    ])));
  }
}

class LabScaffold extends StatelessWidget {
  final String title,description; final Widget child;
  const LabScaffold({super.key,required this.title,required this.description,required this.child});
  @override
  Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),backgroundColor:ink),body:ListView(padding:const EdgeInsets.all(20),children:[Text(description,style:const TextStyle(color:Color(0xFF9AA6C0),height:1.5)),const SizedBox(height:22),child]));
}
class DemoCard extends StatelessWidget {
  final String title; final Widget child;
  const DemoCard({super.key,required this.title,required this.child});
  @override
  Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white.withValues(alpha:.06))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),const SizedBox(height:18),child]));
}

class AnimationPage extends StatefulWidget { const AnimationPage({super.key}); @override State<AnimationPage> createState()=>_AnimationPageState(); }
class _AnimationPageState extends State<AnimationPage> {
  bool expanded=false; double turns=0;
  @override
  Widget build(BuildContext context)=>LabScaffold(title:'Animation Studio',description:'Explore implicit animations, rotation and animated layout changes.',child:Column(children:[
    DemoCard(title:'Animated container',child:Center(child:GestureDetector(onTap:()=>setState(()=>expanded=!expanded),child:AnimatedContainer(duration:const Duration(milliseconds:650),curve:Curves.easeInOutBack,width:expanded?190:112,height:expanded?145:112,decoration:BoxDecoration(gradient:const LinearGradient(colors:[violet,mint]),borderRadius:BorderRadius.circular(expanded?34:60),boxShadow:[BoxShadow(color:violet.withValues(alpha:.25),blurRadius:28)]),child:Icon(expanded?Icons.auto_awesome:Icons.bolt,color:ink,size:38))))),
    const SizedBox(height:14),
    DemoCard(title:'Rotation playground',child:Center(child:Column(children:[AnimatedRotation(turns:turns,duration:const Duration(milliseconds:550),curve:Curves.easeOutBack,child:const Icon(Icons.toys_rounded,size:90,color:violet)),const SizedBox(height:14),FilledButton.tonalIcon(onPressed:()=>setState(()=>turns+=.25),icon:const Icon(Icons.rotate_right),label:const Text('Rotate 90°'))]))),
  ]));
}

class GesturePage extends StatefulWidget { const GesturePage({super.key}); @override State<GesturePage> createState()=>_GesturePageState(); }
class _GesturePageState extends State<GesturePage> {
  Offset offset=Offset.zero; int taps=0;
  @override
  Widget build(BuildContext context)=>LabScaffold(title:'Gesture Playground',description:'Move the glowing tile around. Tap it to count interactions.',child:DemoCard(title:'Drag + tap',child:Column(children:[
    SizedBox(height:280,child:LayoutBuilder(builder:(context,c)=>Stack(children:[
      Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(color:ink,borderRadius:BorderRadius.circular(18)))),
      Positioned(left:(c.maxWidth-76)/2+offset.dx,top:102+offset.dy,child:GestureDetector(onPanUpdate:(d)=>setState(()=>offset=Offset((offset.dx+d.delta.dx).clamp(-c.maxWidth/2+38,c.maxWidth/2-38).toDouble(),(offset.dy+d.delta.dy).clamp(-102,102).toDouble())),onTap:()=>setState(()=>taps++),child:Container(width:76,height:76,decoration:BoxDecoration(gradient:const LinearGradient(colors:[violet,mint]),borderRadius:BorderRadius.circular(25),boxShadow:[BoxShadow(color:violet.withValues(alpha:.3),blurRadius:22)]),child:const Icon(Icons.open_with_rounded,color:ink,size:32)))),
    ]))),
    const SizedBox(height:12),Text('Tapped $taps times',style:const TextStyle(color:mint,fontWeight:FontWeight.w700)),
    TextButton(onPressed:()=>setState(() { offset=Offset.zero; taps=0; }),child:const Text('Reset playground')),
  ])));
}

class UiPage extends StatefulWidget { const UiPage({super.key}); @override State<UiPage> createState()=>_UiPageState(); }
class _UiPageState extends State<UiPage> {
  bool enabled=true; double value=.42;
  @override
  Widget build(BuildContext context)=>LabScaffold(title:'UI Showcase',description:'Expressive controls with live state and feedback.',child:Column(children:[
    DemoCard(title:'Buttons',child:Wrap(spacing:10,runSpacing:10,children:[
      FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('That was a satisfying tap.'))),child:const Text('Primary action')),
      OutlinedButton(onPressed:()=>setState(()=>enabled=!enabled),child:const Text('Toggle state')),
      IconButton.filledTonal(onPressed:()=>setState(()=>enabled=!enabled),icon:const Icon(Icons.favorite_rounded)),
    ])),
    const SizedBox(height:14),
    DemoCard(title:'Controls',child:Column(children:[
      SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Interactive mode'),value:enabled,onChanged:(v)=>setState(()=>enabled=v)),
      Slider(value:value,onChanged:enabled?(v)=>setState(()=>value=v):null),
      Text('Slider value: ${(value*100).round()}%',style:const TextStyle(color:mint)),
    ])),
  ]));
}

class PhysicsPage extends StatefulWidget { const PhysicsPage({super.key}); @override State<PhysicsPage> createState()=>_PhysicsPageState(); }
class _PhysicsPageState extends State<PhysicsPage> with SingleTickerProviderStateMixin {
  late final AnimationController controller=AnimationController(vsync:this,duration:const Duration(milliseconds:900));
  late final Animation<double> bounce=CurvedAnimation(parent:controller,curve:Curves.bounceOut);
  @override void dispose(){controller.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>LabScaffold(title:'Physics Lab',description:'Trigger a springy bounce and watch the motion settle.',child:DemoCard(title:'Bounce experiment',child:Column(children:[
    SizedBox(height:210,child:Center(child:AnimatedBuilder(animation:bounce,builder:(_,child)=>Transform.translate(offset:Offset(0,-115*bounce.value),child:child),child:Container(width:76,height:76,decoration:BoxDecoration(color:const Color(0xFF73B7FF),borderRadius:BorderRadius.circular(26),boxShadow:[BoxShadow(color:const Color(0xFF73B7FF).withValues(alpha:.3),blurRadius:25)]),child:const Icon(Icons.bubble_chart_rounded,color:ink,size:36))))),
    FilledButton.icon(onPressed:()=>controller.forward(from:0),icon:const Icon(Icons.play_arrow_rounded),label:const Text('Bounce')),
  ])));
}

class GraphicsPage extends StatefulWidget { const GraphicsPage({super.key}); @override State<GraphicsPage> createState()=>_GraphicsPageState(); }
class _GraphicsPageState extends State<GraphicsPage> {
  double hue=0;
  @override
  Widget build(BuildContext context)=>LabScaffold(title:'Custom Graphics',description:'A CustomPainter canvas with adjustable color and layered geometry.',child:DemoCard(title:'Painter playground',child:Column(children:[
    SizedBox(height:250,width:double.infinity,child:ClipRRect(borderRadius:BorderRadius.circular(18),child:CustomPaint(painter:OrbPainter(hue)))),
    const SizedBox(height:15),Slider(value:hue,onChanged:(v)=>setState(()=>hue=v)),
    const Text('Change the color blend',style:TextStyle(color:mint)),
  ])));
}
class OrbPainter extends CustomPainter {
  final double hue; OrbPainter(this.hue);
  @override
  void paint(Canvas canvas,Size size) {
    final rect=Offset.zero&size;
    canvas.drawRect(rect,Paint()..shader=const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF211C43),Color(0xFF102E38)]).createShader(rect));
    final center=Offset(size.width/2,size.height/2);
    final color=HSVColor.fromAHSV(1,265+hue*80,.55,1).toColor();
    for(var i=3;i>=0;i--){final radius=34.0+i*22;canvas.drawCircle(center+Offset(math.cos(i*.8)*28,math.sin(i*.8)*18),radius,Paint()..color=color.withValues(alpha:.10+i*.035)..maskFilter=const MaskFilter.blur(BlurStyle.normal,2));}
    final p=Paint()..shader=RadialGradient(colors:[Colors.white.withValues(alpha:.9),color,const Color(0xFF28204F)]).createShader(Rect.fromCircle(center:center,radius:57));
    canvas.drawCircle(center,57,p);
    canvas.drawCircle(center.translate(-18,-20),10,Paint()..color=Colors.white.withValues(alpha:.55));
  }
  @override bool shouldRepaint(covariant OrbPainter old)=>old.hue!=hue;
}
