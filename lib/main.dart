
import 'package:flutter/material.dart';
import 'splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Académica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF023052),
          primary: const Color(0xFF023052),
          secondary: const Color(0xFFFFCC00),
        ),
        useMaterial3: true,
      ),
     home: const SplashScreen(), 
    );
  }
}

class PromedioPage extends StatefulWidget {
  const PromedioPage({super.key});

  @override
  State<PromedioPage> createState() => _PromedioPageState();
}

class _PromedioPageState extends State<PromedioPage> {
  bool _pesosExpandidos = false;

  // --- NOTAS ---
  final _u1Es = TextEditingController();
  final _u1Ep = TextEditingController();
  final _u2Es = TextEditingController();
  final _u2Ep = TextEditingController();
  final _u3Es = TextEditingController();
  final _u3Ep = TextEditingController();
  final _ecg = TextEditingController();

  // --- PESOS (Valores por defecto de tu imagen) ---
  final _wU1Es = TextEditingController(text: "5");
  final _wU1Ep = TextEditingController(text: "15");
  final _wU2Es = TextEditingController(text: "5");
  final _wU2Ep = TextEditingController(text: "30");
  final _wU3Es = TextEditingController(text: "10");
  final _wU3Ep = TextEditingController(text: "25");
  
  final _wTotalEs = TextEditingController(text: "20");
  final _wTotalEp = TextEditingController(text: "70");
  final _wTotalEcg = TextEditingController(text: "10");
  
  final _notaMinima = TextEditingController(text: "13"); // Configurado a 13

  double? _notaFinal;
  String _mensaje = "";
  Color _colorEstado = Colors.red;

  void _calcular() {
    setState(() {
      // Captura de notas
      double nU1es = double.tryParse(_u1Es.text) ?? 0;
      double nU1ep = double.tryParse(_u1Ep.text) ?? 0;
      double nU2es = double.tryParse(_u2Es.text) ?? 0;
      double nU2ep = double.tryParse(_u2Ep.text) ?? 0;
      double nU3es = double.tryParse(_u3Es.text) ?? 0;
      double nU3ep = double.tryParse(_u3Ep.text) ?? 0;
      double nEcg = double.tryParse(_ecg.text) ?? 0;

      // Captura de pesos
      double wU1es = double.tryParse(_wU1Es.text) ?? 0;
      double wU1ep = double.tryParse(_wU1Ep.text) ?? 0;
      double wU2es = double.tryParse(_wU2Es.text) ?? 0;
      double wU2ep = double.tryParse(_wU2Ep.text) ?? 0;
      double wU3es = double.tryParse(_wU3Es.text) ?? 0;
      double wU3ep = double.tryParse(_wU3Ep.text) ?? 0;
      
      double wT_Es = (double.tryParse(_wTotalEs.text) ?? 20) / 100;
      double wT_Ep = (double.tryParse(_wTotalEp.text) ?? 70) / 100;
      double wT_Ecg = (double.tryParse(_wTotalEcg.text) ?? 10) / 100;
      double minAprobacion = double.tryParse(_notaMinima.text) ?? 13.0;

      // 1. Calcular Promedio Ponderado de Productos (EP)
      double sumaPesosEp = wU1ep + wU2ep + wU3ep;
      double promedioEP = sumaPesosEp > 0 
          ? (nU1ep * wU1ep + nU2ep * wU2ep + nU3ep * wU3ep) / sumaPesosEp 
          : 0;

      // 2. Calcular Promedio Ponderado Formativo (ES)
      double sumaPesosEs = wU1es + wU2es + wU3es;
      double promedioES = sumaPesosEs > 0 
          ? (nU1es * wU1es + nU2es * wU2es + nU3es * wU3es) / sumaPesosEs 
          : 0;

      // --- LÓGICA DE NEGOCIO ---
      if (promedioEP < 12.50) {
        // REGLA (**): Si EP < 12.5, la nota final es directamente el promedio de EP
        _notaFinal = promedioEP;
        _mensaje = "Desaprobado (EP < 12.5)";
        _colorEstado = Colors.red.shade900;
      } else {
        // REGLA (*): Si EP >= 12.5, se aplica la fórmula ponderada global
        _notaFinal = (promedioES * wT_Es) + (promedioEP * wT_Ep) + (nEcg * wT_Ecg);
        
        // Verificar si alcanza la nota mínima de 13
        if (_notaFinal! >= minAprobacion) {
          _mensaje = "¡Aprobado!";
          _colorEstado = const Color(0xFF023052); // Azul oscuro
        } else {
          _mensaje = "Desaprobado (Nota < $minAprobacion)";
          _colorEstado = Colors.red.shade900;
        }
      }
    });
  }

  void _reset() {
    setState(() {
      for (var c in [_u1Es, _u1Ep, _u2Es, _u2Ep, _u3Es, _u3Ep, _ecg]) {
        c.clear();
      }
      _notaFinal = null;
      _mensaje = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1E4E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF023052),
        title: const Text("Calculadora Académica", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CONFIGURACIÓN DE PESOS (COLAPSABLE)
            Card(
              elevation: 0,
              color: Colors.white.withOpacity(0.9),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => setState(() => _pesosExpandidos = !_pesosExpandidos),
                    title: const Text("CONFIGURACIÓN DE PESOS Y MÍNIMOS", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF023052))),
                    trailing: Icon(_pesosExpandidos ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    dense: true,
                  ),
                  if (_pesosExpandidos)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: [
                          _buildWeightRow("U1", _wU1Es, _wU1Ep),
                          _buildWeightRow("U2", _wU2Es, _wU2Ep),
                          _buildWeightRow("U3", _wU3Es, _wU3Ep),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(child: _buildSmallInput(_wTotalEs, "T. ES %")),
                              const SizedBox(width: 5),
                              Expanded(child: _buildSmallInput(_wTotalEp, "T. EP %")),
                              const SizedBox(width: 5),
                              Expanded(child: _buildSmallInput(_wTotalEcg, "T. ECG %")),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildSmallInput(_notaMinima, "NOTA MÍNIMA PARA APROBAR"),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            _buildUnidadCard("UNIDAD 1", _u1Es, "Nota ES", _u1Ep, "Nota EP"),
            _buildUnidadCard("UNIDAD 2", _u2Es, "Nota ES", _u2Ep, "Nota EP"),
            _buildUnidadCard("UNIDAD 3", _u3Es, "Nota ES", _u3Ep, "Nota EP"),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _ecg,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Nota ECG (Competencia Genérica)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star, color: Color(0xFFFFCC00)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calcular,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF023052),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("CALCULAR"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text("RESET"),
                  ),
                ),
              ],
            ),

            if (_notaFinal != null) ...[
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC00),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  children: [
                    const Text("PROMEDIO FINAL", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_notaFinal!.toStringAsFixed(2), 
                      style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: _colorEstado)),
                    Text(_mensaje, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _colorEstado)),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildWeightRow(String label, TextEditingController c1, TextEditingController c2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: _buildSmallInput(c1, "ES %")),
          const SizedBox(width: 10),
          Expanded(child: _buildSmallInput(c2, "EP %")),
        ],
      ),
    );
  }

  Widget _buildSmallInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildUnidadCard(String titulo, TextEditingController c1, String l1, TextEditingController c2, String l2) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF023052), fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: c1, decoration: InputDecoration(labelText: l1, border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: c2, decoration: InputDecoration(labelText: l2, border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
