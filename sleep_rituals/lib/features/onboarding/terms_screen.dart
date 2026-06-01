import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _isAdult = false;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;

  void _acceptTerms() async {
    if (!_isAdult || !_agreedToTerms || !_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Поставьте все галочки')),
      );
      return;
    }

    final box = Hive.box('settings');
    await box.put('accepted_terms', true);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05040F),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Прежде чем начать, пожалуйста,\nознакомьтесь с условиями',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('📋 Пользовательское соглашение'),
                    _buildBulletPoint('Приложение «Sleep Rituals» предназначено для улучшения качества сна через ритуалы, будильники и отслеживание прогресса.'),
                    _buildBulletPoint('Пользователь несёт полную ответственность за своё здоровье и использование приложения.'),
                    _buildBulletPoint('Приложение не является медицинским прибором и не заменяет консультацию врача.'),
                    _buildBulletPoint('Все данные хранятся локально на устройстве пользователя и не передаются третьим лицам.'),
                    _buildBulletPoint('Разработчик оставляет за собой право обновлять приложение и изменять функциональность.'),
                    _buildBulletPoint('Запрещается использование приложения в целях, противоречащих законодательству.'),

                    const SizedBox(height: 24),

                    _buildSectionTitle('🔒 Политика конфиденциальности'),
                    _buildBulletPoint('Мы не собираем персональные данные пользователей.'),
                    _buildBulletPoint('Все данные хранятся исключительно на вашем устройстве.'),
                    _buildBulletPoint('Приложение не использует аналитику и не отслеживает действия пользователя.'),

                    const SizedBox(height: 24),

                    _buildSectionTitle('🛡️ Защита детей'),
                    _buildBulletPoint('Приложение предназначено для лиц старше 18 лет.'),
                    _buildBulletPoint('Мы не собираем данные от детей и не направляем им рекламу.'),
                    _buildBulletPoint('Если вам менее 18 лет — используйте приложение под наблюдением родителей.'),
                    _buildBulletPoint('Родители могут обратиться для удаления данных несовершеннолетнего.'),

                    const SizedBox(height: 24),

                    _buildSectionTitle('📷 Разрешения приложения'),
                    _buildBulletPoint('Хранилище — для сохранения данных на устройстве.'),
                    _buildBulletPoint('Все разрешения запрашиваются только в момент использования функций.'),

                    const SizedBox(height: 32),

                    CheckboxListTile(
                      title: const Text('Мне исполнилось 18 лет или я использую приложение с разрешения родителей'),
                      value: _isAdult,
                      onChanged: (v) => setState(() => _isAdult = v ?? false),
                      activeColor: Colors.deepPurpleAccent,
                    ),
                    CheckboxListTile(
                      title: const Text('Я прочитал(а) и принимаю Пользовательское соглашение'),
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      activeColor: Colors.deepPurpleAccent,
                    ),
                    CheckboxListTile(
                      title: const Text('Я согласен(на) с Политикой конфиденциальности'),
                      value: _agreedToPrivacy,
                      onChanged: (v) => setState(() => _agreedToPrivacy = v ?? false),
                      activeColor: Colors.deepPurpleAccent,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _acceptTerms,
                        child: const Text('ПРИНЯТЬ И ПРОДОЛЖИТЬ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, color: Colors.white70)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15.5, height: 1.5, color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}