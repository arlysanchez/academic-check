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

// Clase para manejar los datos de cada unidad de forma dinámica
class UnidadData {
  final TextEditingController nEs = TextEditingController(); // Nota ES
  final TextEditingController nEp = TextEditingController(); // Nota EP
  final TextEditingController wEs = TextEditingController(text: "5");  // Peso ES
  final TextEditingController wEp = TextEditingController(text: "20"); // Peso EP

  void dispose() {
    nEs.dispose();
    nEp.dispose();
    wEs.dispose();
    wEp.dispose();
  }
}

class PromedioPage extends StatefulWidget {
  const PromedioPage({super.key});

  @override
  State<PromedioPage> createState() => _PromedioPageState();
}

class _PromedioPageState extends State<PromedioPage> {
  bool _pesosExpandidos = false;
  
  // Lista dinámica de unidades
  final List<UnidadData> _unidades = [UnidadData(), UnidadData(), UnidadData()];

  // --- CONFIGURACIÓN GLOBAL ---
  final _ecg = TextEditingController();
  final _wTotalEs = TextEditingController(text: "20");
  final _wTotalEp = TextEditingController(text: "70");
  final _wTotalEcg = TextEditingController(text: "10");
  final _notaMinima = TextEditingController(text: "12.5"); // Umbral de aprobación

  double? _notaFinal;
  String _mensaje = "";
  Color _colorEstado = Colors.red;

  void _agregarUnidad() {
    setState(() {
      _unidades.add(UnidadData());
    });
  }

  void _eliminarUnidad(int index) {
    setState(() {
      if (_unidades.length > 1) {
        _unidades[index].dispose();
        _unidades.removeAt(index);
      }
    });
  }

  void _calcular() {
    setState(() {
      double sumaPonderadaES = 0;
      double sumaPesosES = 0;
      double sumaPonderadaEP = 0;
      double sumaPesosEP = 0;

      // 1. Recorrer todas las unidades dinámicas
      for (var u in _unidades) {
        double notaES = double.tryParse(u.nEs.text) ?? 0;
        double notaEP = double.tryParse(u.nEp.text) ?? 0;
        double pesoES = double.tryParse(u.wEs.text) ?? 0;
        double pesoEP = double.tryParse(u.wEp.text) ?? 0;

        sumaPonderadaES += (notaES * pesoES);
        sumaPesosES += pesoES;
        sumaPonderadaEP += (notaEP * pesoEP);
        sumaPesosEP += pesoEP;
      }

      // Promedios ponderados de los componentes
      double promedioES = sumaPesosES > 0 ? sumaPonderadaES / sumaPesosES : 0;
      double promedioEP = sumaPesosEP > 0 ? sumaPonderadaEP / sumaPesosEP : 0;
      
      // Datos globales
      double nEcg = double.tryParse(_ecg.text) ?? 0;
      double wT_Es = (double.tryParse(_wTotalEs.text) ?? 20) / 100;
      double wT_Ep = (double.tryParse(_wTotalEp.text) ?? 70) / 100;
      double wT_Ecg = (double.tryParse(_wTotalEcg.text) ?? 10) / 100;
      double minAprobacion = double.tryParse(_notaMinima.text) ?? 12.5;

      // --- LÓGICA ESTRICTA ---
      if (promedioEP < 12.50) {
        // REGLA DE BLOQUEO: Si EP < 12.5, la nota final es el promedio de EP
        _notaFinal = promedioEP;
        _mensaje = "Desaprobado (EP < 12.5)";
        _colorEstado = Colors.red.shade900;
      } else {
        // REGLA GENERAL: 20% ES + 70% EP + 10% ECG
        _notaFinal = (promedioES * wT_Es) + (promedioEP * wT_Ep) + (nEcg * wT_Ecg);
        
        if (_notaFinal! >= minAprobacion) {
          _mensaje = "¡Aprobado!";
          _colorEstado = const Color(0xFF023052);
        } else {
          _mensaje = "Desaprobado";
          _colorEstado = Colors.red.shade900;
        }
      }
    });
  }

  void _reset() {
    setState(() {
      for (var u in _unidades) {
        u.nEs.clear();
        u.nEp.clear();
      }
      _ecg.clear();
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
            // CONFIGURACIÓN GLOBAL
            Card(
              elevation: 0,
              color: Colors.white.withOpacity(0.9),
              child: ExpansionTile(
                title: const Text("CONFIGURACIÓN GLOBAL Y PESOS", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF023052))),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildSmallInput(_wTotalEs, "Total ES %")),
                            const SizedBox(width: 5),
                            Expanded(child: _buildSmallInput(_wTotalEp, "Total EP %")),
                            const SizedBox(width: 5),
                            Expanded(child: _buildSmallInput(_wTotalEcg, "Total ECG %")),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildSmallInput(_notaMinima, "NOTA MÍNIMA APROBACIÓN (Ej: 12.5)"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // LISTA DE UNIDADES DINÁMICAS
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _unidades.length,
              itemBuilder: (context, index) {
                return _buildUnidadCard(index);
              },
            ),

            // BOTÓN AÑADIR
            TextButton.icon(
              onPressed: _agregarUnidad,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Añadir Unidad"),
            ),

            const SizedBox(height: 10),
            
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
                    Text(_mensaje, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _colorEstado)),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildUnidadCard(int index) {
    final u = _unidades[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("UNIDAD ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF023052))),
                if (_unidades.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                    onPressed: () => _eliminarUnidad(index),
                  )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: _buildSmallInput(u.wEs, "Peso ES %")),
                const SizedBox(width: 10),
                Expanded(child: _buildSmallInput(u.wEp, "Peso EP %")),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: u.nEs, decoration: const InputDecoration(labelText: "Nota ES", border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: u.nEp, decoration: const InputDecoration(labelText: "Nota EP", border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
              ],
            )
          ],
        ),
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
}
