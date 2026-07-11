// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHomeScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero / Header ───────────────────────────────────────────
              _HeroSection(),
              SizedBox(height: 24.h),

              // ── How It Works ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'How It Works'),
                    SizedBox(height: 14.h),
                    _HowItWorksCard(
                      step: '1',
                      title: 'Upload docs or meeting audio',
                      description:
                          'Upload PDFs, DOCX files, or meeting audio. Requra AI parses all content automatically.',
                      duration: '10 sec',
                      icon: Icons.upload_file_outlined,
                    ),
                    SizedBox(height: 12.h),
                    _HowItWorksCard(
                      step: '2',
                      title: 'Generate Structured Specs',
                      description:
                          'Instantly transform messy notes into standardised user stories and acceptance criteria.',
                      duration: '10 - 60 sec',
                      icon: Icons.auto_awesome_outlined,
                    ),
                    SizedBox(height: 12.h),
                    _HowItWorksCard(
                      step: '3',
                      title: 'Export to Jira in Seconds',
                      description:
                          'Once your backlog is ready, export your structured requirements as an Excel file or share with stakeholders.',
                      duration: '10 sec',
                      icon: Icons.ios_share_outlined,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // ── FAQ ─────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: "FAQ's"),
                    SizedBox(height: 14.h),
                    _FaqItem(
                      question: "What file types does Requra support?",
                      answer:
                          "Requra supports PDFs, DOCX, MP3, and MP4 files for processing.",
                    ),
                    _FaqItem(
                      question: "How accurate is the AI extraction?",
                      answer:
                          "Our AI achieves ~95% accuracy on structured documents and ~85% on audio recordings.",
                    ),
                    _FaqItem(
                      question:
                          "Can I export requirements to any project tool?",
                      answer:
                          "Yes – you can export to Jira, Excel, or share via link.",
                    ),
                    _FaqItem(
                      question: "Is my data secure?",
                      answer:
                          "All data is encrypted at rest and in transit. We never share your data.",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // ── CTA Card ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _CtaCard(),
              ),

              SizedBox(height: 28.h),

              // ── Footer ───────────────────────────────────────────────────
              _FooterSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFF5A3D9A), Color(0xFF3B2378)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar logo + actions
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'REQURA AI',
                  style: semiBoldStyle(
                    fontSize: FontSize.font12,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                _WhiteIconBtn(icon: Icons.notifications_outlined),
                SizedBox(width: 8.w),
                _WhiteIconBtn(icon: Icons.menu_rounded),
              ],
            ),

            SizedBox(height: 30.h),

            // Badge
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '✦ WELCOME TO REQURA AI',
                style: regularStyle(
                  fontSize: FontSize.font10,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 14.h),

            Text(
              'Turn Messy\nConversations\nInto Structured\nRequirements.',
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontWeight: FontWeight.w900,
                fontSize: 26.sp,
                color: Colors.white,
                height: 1.25,
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              'Upload PDFs, DOCX, or audio. Requra AI creates user stories, acceptance criteria, and a clean backlog in minutes.',
              style: regularStyle(
                fontSize: FontSize.font13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),

            SizedBox(height: 24.h),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Get started for free',
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.play_circle_outline,
                    color: Colors.white, size: 18.sp),
                label: Text(
                  'Watch Video',
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Key Features title
            Row(
              children: [
                Text('⊹ ', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
                Text(
                  'Key Features',
                  style: semiBoldStyle(
                    fontSize: FontSize.font18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // Feature cards horizontal scroll
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _FeatureCard(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Smart Requirement\nGeneration',
                    description:
                        'Highlight key decisions, action items, and open questions.',
                  ),
                  _FeatureCard(
                    icon: Icons.category_outlined,
                    title: 'Automatic\nClassification',
                    description:
                        'Separates extracted items into Functional, Non-Functional, and Business Rules.',
                  ),
                  _FeatureCard(
                    icon: Icons.summarize_outlined,
                    title: 'Executive\nSummary',
                    description:
                        'Produces a concise summary highlighting key decisions and open questions.',
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            Center(
              child: TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore More',
                      style: semiBoldStyle(
                        fontSize: FontSize.font14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 12.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteIconBtn extends StatelessWidget {
  const _WhiteIconBtn({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: Colors.white, size: 17.sp),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxHeight: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 22),
              const SizedBox(height: 8),
              Text(
                title,
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: regularStyle(
                  fontSize: FontSize.font10,
                  color: Colors.white.withOpacity(0.75),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── How It Works ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('⊹ ', style: TextStyle(color: AppColors.primary, fontSize: 16.sp)),
        Text(
          title,
          style: semiBoldStyle(
            fontSize: FontSize.font18,
            color: AppColors.darkgrey,
          ),
        ),
      ],
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({
    required this.step,
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
  });

  final String step;
  final String title;
  final String description;
  final String duration;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B6FD8), AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                step,
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.darkgrey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 12.sp, color: AppColors.lightgrey),
                    SizedBox(width: 3.w),
                    Text(
                      duration,
                      style: regularStyle(
                        fontSize: FontSize.font10,
                        color: AppColors.lightgrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.lightPrimary, size: 22.sp),
        ],
      ),
    );
  }
}

// ── FAQ ───────────────────────────────────────────────────────────────────────

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEEEEF0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          childrenPadding:
              EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          trailing: Icon(
            _expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: AppColors.lightgrey,
            size: 20.sp,
          ),
          title: Text(
            widget.question,
            style: semiBoldStyle(
              fontSize: FontSize.font13,
              color: AppColors.darkgrey,
            ),
          ),
          children: [
            Text(
              widget.answer,
              style: regularStyle(
                fontSize: FontSize.font12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CTA Card ─────────────────────────────────────────────────────────────────

class _CtaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B5DD4), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start your next\nproject with clearer\nrequirements.',
            style: boldStyle(
              fontSize: FontSize.font18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Take documents and meeting notes into user stories, acceptance criteria, and a clean backlog in minutes.',
            style: regularStyle(
              fontSize: FontSize.font12,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get started for free',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.play_circle_outline,
                  color: Colors.white, size: 16.sp),
              label: Text(
                'Watch Video',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: Colors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white60),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkPrimary,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'REQURA.AI',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'We turning your documents and meeting\nnotes into specific requirements.',
            style: regularStyle(
              fontSize: FontSize.font12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FooterColumn(title: 'Platform', items: const [
                'Features',
                'How It Works',
                'AI Business Writer',
              ]),
              SizedBox(width: 24.w),
              _FooterColumn(title: 'Company', items: const [
                'Blog',
                'Careers',
                'News',
              ]),
              SizedBox(width: 24.w),
              _FooterColumn(title: 'Resources', items: const [
                'Documentation',
                'Papers',
                'Press',
              ]),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(color: Colors.white.withOpacity(0.2)),
          SizedBox(height: 10.h),
          Text(
            '© 2026 Requra AI. All rights reserved.',
            style: regularStyle(
              fontSize: FontSize.font10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: semiBoldStyle(
            fontSize: FontSize.font12,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              item,
              style: regularStyle(
                fontSize: FontSize.font11,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


