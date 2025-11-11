// =======================================================================
// screens/auth/otp_verification_screen.dart
// =======================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/widgets/primary_button.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper for OTP boxes
    Widget _buildOtpBox() {
      return SizedBox(
        width: 60,
        height: 60,
        child: TextFormField(
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
          style: Theme.of(context).textTheme.headlineMedium,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận OTP'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Image Placeholder
                Icon(
                  Icons.phonelink_lock,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nhập 4 mã số đã được gửi đến email của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),

                // 2. Form Fields (OTP Boxes)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOtpBox(),
                    _buildOtpBox(),
                    _buildOtpBox(),
                    _buildOtpBox(),
                  ],
                ),
                const SizedBox(height: 32),

                // 3. Button
                PrimaryButton(
                  text: 'Xác nhận',
                  onPressed: () {
                    // TODO: Add OTP verification logic
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.resetPassword,
                      (route) => route.isFirst,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}