// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:eventpro_app/controller/login_controller.dart';
import 'package:eventpro_app/controller/profile_controller.dart';
import 'package:eventpro_app/models/user_model.dart';
import 'package:eventpro_app/utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _cpfController;
  late TextEditingController _dateOfBirthController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastnameController = TextEditingController();
    _phoneController = TextEditingController();
    _cpfController = TextEditingController();
    _dateOfBirthController = TextEditingController();

    // Fetch user details when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginController = Provider.of<LoginController>(context, listen: false);
      if (loginController.currentUser?.id != null) {
        Provider.of<ProfileController>(context, listen: false)
            .fetchUserDetails(loginController.currentUser!.id!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void _updateControllers(User user) {
    _nameController.text = user.name;
    _lastnameController.text = user.lastname;
    _phoneController.text = user.phone != null ? Validators.formatPhone(user.phone!) : '';
    _cpfController.text = user.cpf != null ? Validators.formatCPF(user.cpf!) : '';
    _dateOfBirthController.text =
        user.dateOfBirth != null ? Validators.formatDate(user.dateOfBirth!) : '';
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      final profileController = Provider.of<ProfileController>(context, listen: false);
      final userId = profileController.user!.id!;

      final updatedData = {
        'name': _nameController.text,
        'lastname': _lastnameController.text,
        'phone': _phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        // 'cpf': _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''), // CPF is usually not editable
        // 'dateOfBirth': ... // Date handling needs a date picker
      };

      final success = await profileController.updateUserDetails(userId, updatedData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        setState(() {
          _isEditMode = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(profileController.error ?? 'Falha ao atualizar o perfil.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Editar Perfil" : "Meu Perfil"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: _buildAppBarActions(),
      ),
      body: Consumer<ProfileController>(
        builder: (context, profileController, child) {
          if (profileController.isLoading && profileController.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileController.error != null && profileController.user == null) {
            return Center(child: Text("Erro: ${profileController.error}"));
          }

          final User? user = profileController.user;

          if (user == null) {
            // This might happen if the user logs out.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/login');
            });
            return const Center(child: Text("Nenhum usuário logado."));
          }
          
          // Update text controllers whenever the user data changes
          _updateControllers(user);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const Divider(height: 40),
                  _buildProfileInfo(user),
                   if (!_isEditMode) ...[
                    const SizedBox(height: 30),
                    _buildChangePasswordButton(user),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isEditMode) {
      return [
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => setState(() => _isEditMode = false),
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _handleSaveChanges,
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => setState(() => _isEditMode = true),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Provider.of<LoginController>(context, listen: false).logout();
            context.go('/login');
          },
        ),
      ];
    }
  }
  
  Widget _buildProfileHeader(User user) {
     return Column(
       children: [
         CircleAvatar(
           radius: 60,
           backgroundColor: Theme.of(context).colorScheme.secondary,
           child: Text(
             user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
             style: const TextStyle(fontSize: 48, color: Colors.white),
           ),
         ),
         const SizedBox(height: 20),
         Text(
           '${user.name} ${user.lastname}',
           style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
         ),
         Text(
           user.email,
           style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
         ),
       ],
     );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      children: [
        _buildEditableField(
          controller: _nameController,
          label: 'Nome',
          icon: Icons.person,
          validator: (value) => Validators.validateName(value, fieldName: 'Nome'),
        ),
        _buildEditableField(
          controller: _lastnameController,
          label: 'Sobrenome',
          icon: Icons.person_outline,
          validator: (value) => Validators.validateName(value, fieldName: 'Sobrenome'),
        ),
        _buildEditableField(
          controller: _phoneController,
          label: 'Telefone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: Validators.validatePhone,
          onChanged: (value) {
            _phoneController.value = TextEditingValue(
              text: Validators.formatPhone(value),
              selection: TextSelection.collapsed(offset: Validators.formatPhone(value).length),
            );
          },
        ),
        _buildEditableField(
          controller: _cpfController,
          label: 'CPF',
          icon: Icons.credit_card,
          isEditable: false, // CPF is generally not editable
        ),
        _buildEditableField(
          controller: _dateOfBirthController,
          label: 'Data de Nascimento',
          icon: Icons.cake,
          isEditable: false, // Date of birth is generally not editable
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isEditable = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        readOnly: !_isEditMode || !isEditable,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: const OutlineInputBorder(),
          filled: !_isEditMode || !isEditable,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildChangePasswordButton(User user) {
     return ElevatedButton.icon(
       onPressed: () => _showChangePasswordDialog(user.email, user.id!),
       icon: const Icon(Icons.lock),
       label: const Text('Alterar Senha'),
       style: ElevatedButton.styleFrom(
         backgroundColor: Theme.of(context).colorScheme.secondary,
         foregroundColor: Colors.white,
         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
       ),
     );
  }

  void _showChangePasswordDialog(String email, String userId) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar Senha'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha Antiga'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nova Senha'),
                  validator: (v) => v!.length < 8 ? 'A senha deve ter pelo menos 8 caracteres' : null,
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmar Nova Senha'),
                  validator: (v) => v != newPasswordController.text ? 'As senhas não coincidem' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  final profileController = Provider.of<ProfileController>(context, listen: false);
                  final success = await profileController.changePassword(
                    email: email,
                    userId: userId,
                    oldPassword: oldPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if(mounted) {
                     if (success) {
                       Navigator.of(context).pop();
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Colors.green),
                       );
                     } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text(profileController.error ?? 'Falha ao alterar a senha.'),
                           backgroundColor: Colors.red,
                         ),
                       );
                     }
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}