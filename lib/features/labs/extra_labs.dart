import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'labs.dart';

class CanvasLab extends StatefulWidget {
  const CanvasLab({super.key});
  @override
  State<CanvasLab> createState() => _CanvasLabState();
}
class _CanvasLabState extends State<CanvasLab> {
  final List<_Stroke> strokes = [];
  final List<_Stroke> redo = [];
  Color color = const Color(0xFF806BFF);
  double width = 6;
  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Canvas Lab',
    description: 'Draw directly on a Flutter canvas with brush colors, undo and redo.',
    child: LabCardPanel(title: 'Drawing canvas', child: Column(children: [
      Container(height: 320, width: double.infinity, clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
        child: GestureDetector(
          onPanStart: (d) => setState(() { redo.clear(); strokes.add(_Stroke(color, width, [d.localPosition])); }),
          onPanUpdate: (d) => setState(() { if (strokes.isNotEmpty) strokes.last.points.add(d.localPosition); }),
          child: CustomPaint(painter: _DrawingPainter(strokes), child: const SizedBox.expand()),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 10, children: [
        for (final c in const [Color(0xFF806BFF), Color(0xFF21B891), Color(0xFFFF647C), Color(0xFFFFB547), Color(0xFF3498DB), Color(0xFF202638)])
          InkWell(onTap: () => setState(() => color = c), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: color == c ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 3)))),
      ]),
      Row(children: [const Text('Brush'), Expanded(child: Slider(value: width, min: 2, max: 22, onChanged: (v) => setState(() => width = v))), Text(width.round().toString())]),
      Wrap(spacing: 8, children: [
        OutlinedButton.icon(onPressed: strokes.isEmpty ? null : () => setState(() => redo.add(strokes.removeLast())), icon: const Icon(Icons.undo), label: const Text('Undo')),
        OutlinedButton.icon(onPressed: redo.isEmpty ? null : () => setState(() => strokes.add(redo.removeLast())), icon: const Icon(Icons.redo), label: const Text('Redo')),
        TextButton.icon(onPressed: strokes.isEmpty ? null : () => setState(() { strokes.clear(); redo.clear(); }), icon: const Icon(Icons.delete_outline), label: const Text('Clear')),
      ]),
    ])),
  );
}
class _Stroke {
  _Stroke(this.color, this.width, this.points);
  final Color color; final double width; final List<Offset> points;
}
class _DrawingPainter extends CustomPainter {
  _DrawingPainter(this.strokes);
  final List<_Stroke> strokes;
  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final p = Paint()..color=s.color..strokeWidth=s.width..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round..style=PaintingStyle.stroke;
      if (s.points.length == 1) { canvas.drawCircle(s.points.first, s.width/2, p..style=PaintingStyle.fill); }
      else { final path=Path()..moveTo(s.points.first.dx,s.points.first.dy); for(final point in s.points.skip(1)){path.lineTo(point.dx,point.dy);} canvas.drawPath(path,p); }
    }
  }
  @override
  bool shouldRepaint(covariant _DrawingPainter old) => true;
}

enum _ChartKind { bars, line, pie }
class ChartsLab extends StatefulWidget {
  const ChartsLab({super.key});
  @override
  State<ChartsLab> createState() => _ChartsLabState();
}
class _ChartsLabState extends State<ChartsLab> {
  _ChartKind kind = _ChartKind.bars;
  double value = .65;
  @override
  Widget build(BuildContext context) => LabPage(title: 'Charts Lab', description: 'Interactive custom-painted bar, line and pie charts with live values.',
    child: LabCardPanel(title: 'Interactive chart', child: Column(children: [
      SegmentedButton<_ChartKind>(segments: const [
        ButtonSegment(value:_ChartKind.bars,label:Text('Bars'),icon:Icon(Icons.bar_chart)),
        ButtonSegment(value:_ChartKind.line,label:Text('Line'),icon:Icon(Icons.show_chart)),
        ButtonSegment(value:_ChartKind.pie,label:Text('Pie'),icon:Icon(Icons.pie_chart)),
      ], selected:{kind}, onSelectionChanged:(v)=>setState(()=>kind=v.first)),
      const SizedBox(height:20),
      SizedBox(height:260,width:double.infinity,child:CustomPaint(painter:_ChartPainter(kind,value))),
      Row(children:[const Text('Live value'),Expanded(child:Slider(value:value,onChanged:(v)=>setState(()=>value=v))),Text('${(value*100).round()}%')]),
    ])),
  );
}
class _ChartPainter extends CustomPainter {
  _ChartPainter(this.kind,this.highlight);
  final _ChartKind kind; final double highlight;
  static const colors=[Color(0xFF806BFF),Color(0xFF21B891),Color(0xFFFFB547),Color(0xFFFF647C),Color(0xFF3498DB)];
  @override
  void paint(Canvas canvas,Size size) {
    final values=[.48,highlight,.82,.38,.68];
    canvas.drawLine(Offset(12,size.height-18),Offset(size.width-8,size.height-18),Paint()..color=Colors.grey..strokeWidth=1);
    if(kind==_ChartKind.bars){
      final gap=12.0, w=(size.width-36-gap*4)/5;
      for(var i=0;i<5;i++){final h=values[i]*(size.height-48);canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18+i*(w+gap),size.height-18-h,w,h),const Radius.circular(8)),Paint()..color=colors[i]);}
    } else if(kind==_ChartKind.line){
      final path=Path();
      for(var i=0;i<5;i++){final p=Offset(18+i*(size.width-36)/4,size.height-18-values[i]*(size.height-48));if(i==0){path.moveTo(p.dx,p.dy);}else{path.lineTo(p.dx,p.dy);}canvas.drawCircle(p,5,Paint()..color=colors[i]);}
      canvas.drawPath(path,Paint()..color=colors.first..strokeWidth=4..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    } else {
      final total=values.reduce((a,b)=>a+b);var start=-math.pi/2;
      final d=math.min(size.width,size.height)-30;final rect=Rect.fromCenter(center:Offset(size.width/2,size.height/2),width:d,height:d);
      for(var i=0;i<5;i++){final sweep=values[i]/total*math.pi*2;canvas.drawArc(rect,start,sweep,true,Paint()..color=colors[i]);start+=sweep;}
      canvas.drawCircle(rect.center,rect.width*.19,Paint()..color=const Color(0xFF111827));
    }
  }
  @override
  bool shouldRepaint(covariant _ChartPainter old)=>old.kind!=kind||old.highlight!=highlight;
}

class DeveloperToolsLab extends StatefulWidget {
  const DeveloperToolsLab({super.key});
  @override
  State<DeveloperToolsLab> createState()=>_DeveloperToolsLabState();
}
class _DeveloperToolsLabState extends State<DeveloperToolsLab> {
  final List<String> events=['Developer tools initialized.'];
  void log(String message)=>setState(()=>events.insert(0,'[${DateTime.now().toLocal().toString().split('.').first}] $message'));
  @override
  Widget build(BuildContext context)=>LabPage(title:'Developer Tools',description:'Inspect runtime details and collect copyable diagnostic logs.',
    child:Column(children:[
      LabCardPanel(title:'Runtime information',child:Column(children:[
        _row('Platform',defaultTargetPlatform.name),
        _row('Build mode',kDebugMode?'Debug':'Release/Profile'),
        _row('Screen','${MediaQuery.sizeOf(context).width.round()} × ${MediaQuery.sizeOf(context).height.round()} dp'),
        _row('Pixel ratio',MediaQuery.devicePixelRatioOf(context).toStringAsFixed(2)),
        _row('Text scale',MediaQuery.textScalerOf(context).scale(1).toStringAsFixed(2)),
      ])),
      const SizedBox(height:12),
      LabCardPanel(title:'Diagnostic console',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Wrap(spacing:8,children:[
          FilledButton.tonal(onPressed:()=>log('Manual test event'),child:const Text('Add test event')),
          OutlinedButton.icon(onPressed:()async{await Clipboard.setData(ClipboardData(text:events.join('\n')));if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Diagnostics copied.')));}},icon:const Icon(Icons.copy),label:const Text('Copy logs')),
          TextButton(onPressed:()=>setState(events.clear),child:const Text('Clear')),
        ]),
        const SizedBox(height:8),
        Container(height:190,width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Theme.of(context).colorScheme.surfaceContainerHighest,borderRadius:BorderRadius.circular(12)),child:ListView(children:events.map((e)=>Padding(padding:const EdgeInsets.symmetric(vertical:3),child:Text(e,style:const TextStyle(fontFamily:'monospace',fontSize:12)))).toList())),
      ])),
    ]),
  );
  Widget _row(String a,String b)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[Expanded(child:Text(a)),Text(b,style:const TextStyle(fontWeight:FontWeight.w700))]));
}
