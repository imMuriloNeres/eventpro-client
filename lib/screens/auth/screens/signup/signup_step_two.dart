import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:eventpro_app/controller/signup_controller.dart';
import 'package:eventpro_app/core/themes/app_colors.dart';

class SignupStepTwoScreen extends StatelessWidget {
  SignupStepTwoScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    height: 60,
                    child: Image.asset(
                      "assets/images/eventPro.png",
                      width: 160,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Adicione seus dados de contato",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'E-mail',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    filled: true,
                    fillColor: AppColors.inputColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) => context.read<SignupController>().email = value,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Telefone',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu telefone';
                    }
                    if (value.length < 11) {
                      return 'Telefone inválido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '(xx) xxxxx-xxxx',
                    filled: true,
                    fillColor: AppColors.inputColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) => context.read<SignupController>().phone = value,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'CPF',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu CPF';
                    }
                    if (value.length < 11) {
                      return 'CPF inválido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Insira seu CPF',
                    filled: true,
                    fillColor: AppColors.inputColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) => context.read<SignupController>().cpf = value,
                ),
                
                const SizedBox(height: 32),
                // Botão Voltar
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/signup/step1'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.bluePrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Voltar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bluePrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botão Próximo
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.go('/signup/step3');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bluePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Próximo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Já possui conta? Faça login',
                      style: TextStyle(
                        color: AppColors.bluePrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}