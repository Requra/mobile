import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/routes/app_routes.dart';

/// Data model for each onboarding page.
class _OnboardingPageData {
  const _OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.highlightedWord,
    required this.description,
  });

  final String imagePath;
  final String title;
  final String highlightedWord; // word within title to color in purple
  final String description;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding1.png',
      title: 'Transform conversations into structured requirements',
      highlightedWord: 'structured requirements',
      description:
          'Requra.ai automatically transform messy notes, documents, and meetings into structured user stories in seconds.',
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding2.png',
      title: 'Collaborate with stakeholders easily',
      highlightedWord: 'stakeholders easily',
      description:
          'Invite stakeholders, gather feedback, and refine requirements together in one place.',
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding3.png',
      title: 'Ready for Development',
      highlightedWord: 'Development',
      description:
          'Export structured requirements to Excel, CSV, or tools like Jira and start building faster.',
    ),
  ];

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Skip button ────────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 12.h, right: 16.w),
                child: GestureDetector(
                  onTap: _navigateToLogin,
                  child: Text(
                    'skip',
                    style: regularStyle(
                      fontSize: FontSize.font16,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (BuildContext context, int index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // ── Page indicator dots ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_pages.length, (int index) {
                  final bool isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: isActive ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.IndicatorBG,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
            ),

            // ── Next / Get Started button ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _goToNextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: semiBoldStyle(
                          fontSize: FontSize.font18,
                          color: AppColors.white,
                        ),
                      ),
                      if (_currentPage < _pages.length - 1) ...[
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward, size: 20.sp),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single onboarding page with image, title (with highlighted word), and
/// description.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: <Widget>[
          // ── Illustration image ───────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // ── Title with highlighted word ───────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              children: <Widget>[
                _buildTitle(),
                SizedBox(height: 16.h),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: regularStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the title text with the highlighted word in purple.
  Widget _buildTitle() {
    final int highlightStart =
        data.title.toLowerCase().indexOf(data.highlightedWord.toLowerCase());

    if (highlightStart == -1) {
      // Fallback: no highlight found — render plain bold text.
      return Text(
        data.title,
        textAlign: TextAlign.center,
        style: boldStyle(
          fontSize: FontSize.font24,
          color: AppColors.black,
        ),
      );
    }

    final String before = data.title.substring(0, highlightStart);
    final String highlighted = data.title.substring(
      highlightStart,
      highlightStart + data.highlightedWord.length,
    );
    final String after =
        data.title.substring(highlightStart + data.highlightedWord.length);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: boldStyle(
          fontSize: FontSize.font24,
          color: AppColors.black,
        ),
        children: <TextSpan>[
          TextSpan(text: before),
          TextSpan(
            text: highlighted,
            style: boldStyle(
              fontSize: FontSize.font24,
              color: AppColors.primaryText,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
