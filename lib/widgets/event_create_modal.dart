import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventCreateModal extends StatefulWidget {
  final String userId;

  const EventCreateModal({super.key, required this.userId});

  @override
  State<EventCreateModal> createState() => _EventCreateModalState();
}

class _EventCreateModalState extends State<EventCreateModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos (sem alteração)
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();

  // MUDANÇA: A categoria única se torna uma lista de categorias selecionadas
  List<String> _selectedCategories = [];
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  // Lista de categorias disponíveis (sem alteração)
  final List<String> _categories = const [
    'Palestra', 'Workshop', 'Evento', 'Tecnologia', 'Música', 'Programação',
    'Negócios', 'Games', 'Esportes', 'Backend', 'Outro',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _additionalInfoController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Funções _selectDate e _selectTime (sem alteração)
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
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  // MUDANÇA: Função de submissão totalmente atualizada para o novo formato JSON
  void _submit() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      // Validação atualizada para a lista de categorias
      if (_selectedDate == null || _startTime == null || _endTime == null || _selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios, incluindo data, horários e pelo menos uma categoria.')),
        );
        return;
      }
      
      setState(() => _isSubmitting = true);

      final startDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _startTime!.hour, _startTime!.minute);
      final endDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _endTime!.hour, _endTime!.minute);

      final imageUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://placehold.co/600x400/004AAD/FFFFFF/png?text=Evento';

      // MUDANÇA: Monta o eventData de acordo com a nova estrutura
      final eventData = {
        'userId': widget.userId, // Chave 'userId'
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'categories': _selectedCategories, // Chave 'categories' como uma lista
        'imageUrl': imageUrl, // Mantido como campo opcional
        'date': startDateTime.toIso8601String(),
        'location': {
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'country': _countryController.text.trim(),
          'additionalInfo': _additionalInfoController.text.trim(),
        },
        'capacity': {
          'max': int.tryParse(_capacityController.text.trim()) ?? 0,
        },
        'schedules': {
          'start': startDateTime.toIso8601String(),
          'end': endDateTime.toIso8601String(),
        },
        // Preço agora é um campo simples no nível principal
        'inscriptionPrice': double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ?? 0.0,
      };
      
      try {
        final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(eventData),
        );

        if (!mounted) return;

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.green, content: Text('Evento criado com sucesso!')),
          );
          Navigator.of(context).pop(true);
        } else {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Ocorreu um erro desconhecido.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text('Falha ao criar evento: $errorMessage (Cód: ${response.statusCode})')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Erro de conexão: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  InputDecoration _decoration(String label, {IconData? icon}) => InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade100,
  );

  // MUDANÇA: Widget para construir os chips de seleção de categoria
  Widget _buildCategoryChips() {
    return FormField<List<String>>(
      initialValue: _selectedCategories,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione pelo menos uma categoria';
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: _decoration('Categorias').copyWith(
                errorText: formFieldState.errorText,
                contentPadding: const EdgeInsets.all(12),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _categories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                        formFieldState.didChange(_selectedCategories);
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }


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
              
              // MUDANÇA: Substituído o Dropdown pelo novo seletor de chips
              _buildCategoryChips(),
              const SizedBox(height: 12),
              
              TextFormField(controller: _descriptionController, maxLines: 3, decoration: _decoration('Descrição'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),

              TextFormField(controller: _imageUrlController, decoration: _decoration('URL da Imagem (Opcional)', icon: Icons.image), keyboardType: TextInputType.url),
              const SizedBox(height: 24),

              const Text("Localização", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
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
              const SizedBox(height: 24),

              const Text("Detalhes do Evento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: TextFormField(controller: _capacityController, keyboardType: TextInputType.number, decoration: _decoration('Capacidade'), validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? 'Número inválido' : null)),
                  const SizedBox(width: 12),
                  // MUDANÇA: O campo de preço agora se refere ao 'inscriptionPrice'
                  Expanded(child: TextFormField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _decoration('Preço Inscrição (R\$)'))),
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
                child: _isSubmitting 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                  : const Text('Cadastrar Evento', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}