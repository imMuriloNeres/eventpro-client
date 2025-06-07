import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http; // Descomente para usar http
// import 'dart:convert'; // Descomente para usar jsonEncode

class EventCreateModal extends StatefulWidget {
  const EventCreateModal({super.key});

  @override
  State<EventCreateModal> createState() => _EventCreateModalState();
}

class _EventCreateModalState extends State<EventCreateModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _additionalInfoController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos de data e horário.')),
        );
        return;
      }
      
      setState(() => _isSubmitting = true);

      // Combina a data e a hora para criar um DateTime completo
      final startDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _startTime!.hour, _startTime!.minute);
      final endDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _endTime!.hour, _endTime!.minute);

      final eventData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': 'standard',
        'date': startDateTime.toIso8601String(), // Usando a data/hora de início
        'location': {
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'country': _countryController.text.trim(),
          'additionalInfo': _additionalInfoController.text.trim(),
        },
        'capacity': {
          'max': int.tryParse(_capacityController.text) ?? 0,
        },
        'schedules': {
          'start': startDateTime.toIso8601String(),
          'end': endDateTime.toIso8601String(),
        },
        'inscription': [
          {
            'price': double.tryParse(_priceController.text) ?? 0,
            'type': 'padrão',
            'discount': 0
          }
        ],
        // ... outros campos que sua API pode precisar
      };
      
      // LÓGICA PARA ENVIAR PARA A API (EXEMPLO COMENTADO)
      /*
      try {
        final uri = Uri.parse('URL_DA_SUA_API_PARA_CRIAR_EVENTO');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(eventData),
        );

        if (response.statusCode == 201) { // 201 Created
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento criado com sucesso!')),
          );
          Navigator.of(context).pop(true); // Retorna true para a HomePage
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao criar evento: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
      */

      // Lógica atual (apenas imprime e fecha)
      print('Dados do Evento: $eventData');
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text('Evento criado com sucesso! (Simulação)')),
      );
      // Passe 'true' para que a HomePage atualize a lista
      Navigator.of(context).pop(true);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade100,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 40, left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cadastrar Evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(controller: _nameController, decoration: _decoration('Nome do evento'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descriptionController, maxLines: 3, decoration: _decoration('Descrição'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _addressController, decoration: _decoration('Endereço'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _cityController, decoration: _decoration('Cidade'), validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _stateController, decoration: _decoration('Estado'), validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _countryController, decoration: _decoration('País'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _additionalInfoController, decoration: _decoration('Informações adicionais (ex: Sala 101)')),
              const SizedBox(height: 12),
              Row(
                children: [
                   Expanded(child: TextFormField(controller: _capacityController, keyboardType: TextInputType.number, decoration: _decoration('Capacidade'), validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? 'Número inválido' : null)),
                   const SizedBox(width: 12),
                   Expanded(child: TextFormField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _decoration('Preço (R\$)'))),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_selectedDate == null ? 'Selecionar data do evento' : 'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(_startTime == null ? 'Selecionar horário de início' : 'Início: ${_startTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: Text(_endTime == null ? 'Selecionar horário de término' : 'Término: ${_endTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: _isSubmitting ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)) : const Text('Cadastrar Evento', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}