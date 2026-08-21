import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/settings/server_settings_screen.dart';
import '../../providers/language_provider.dart';
import '../../widgets/language_switcher.dart';
import '../auth/login_screen.dart';

// ====== الثوابت والألوان ======
const Color kPrimaryBlue = Color(0xFF2563EB);
const Color kTitleBlue = Color(0xFF1D4ED8);
const Color kTextDark = Color(0xFF334155);
const Color kAccentTeal = Color(0xFF14B8A6);
const Color kSoftIndigo = Color(0xFF6366F1);
const double kPagePadding = 24;

const TextStyle kBrandTitle = TextStyle(
  fontFamily: 'Cairo',
  fontWeight: FontWeight.w700,
  color: kPrimaryBlue,
  letterSpacing: .2,
);

const TextStyle kSectionTitle = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kTitleBlue,
);

const TextStyle kHeroTitleDesktop = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 32,
  fontWeight: FontWeight.w800,
  color: kTitleBlue,
  height: 1.25,
);

const TextStyle kHeroTitleMobile = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 24,
  fontWeight: FontWeight.w800,
  color: kTitleBlue,
  height: 1.3,
);

const TextStyle kBody = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 16,
  color: kTextDark,
  height: 1.6,
);

/// شاشة ترحيبية أنيقة بدون تسجيل دخول
/// - منع أي Overflow للنصوص مع الحفاظ على التنسيق
/// - حركات دخول سلسة للنصوص والصور والبطاقات
class UnifiedSplashScreen extends StatelessWidget {
  const UnifiedSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = context.watch<LanguageProvider>().isRTL;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(isRTL, context),
        drawer: _buildDrawer(isRTL, context),
        body: const _Body(),
      ),
    );
  }

  // ========== AppBar ==========
  AppBar _buildAppBar(bool isRTL, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow =
        width < 380; // عرّض صغير: استخدم أيقونة بدلاً من نص لمنع overflow

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0.75,
      shadowColor: Colors.black12,
      centerTitle: false, // تجنّب تراكب العنوان مع الأزرار على الشاشات الصغيرة
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kPrimaryBlue.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medical_services, color: kPrimaryBlue),
          ),
          const SizedBox(width: 10),
          // اجعل النص قابلاً للتمدّد مع إخفاء الفائض بنقاط
          Flexible(
            child: Text(
              isRTL ? 'المنصة الطبية' : 'Medical Platform',
              style: kBrandTitle,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: [
        const LanguageSwitcher(isCompact: true, showText: false),
        if (isNarrow)
          IconButton(
            tooltip: isRTL ? 'تسجيل الدخول' : 'Login',
            icon: const Icon(Icons.login, color: kPrimaryBlue),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        else
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(fontFamily: 'Cairo', color: kPrimaryBlue),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(width: 8),
      ],
      foregroundColor: kPrimaryBlue,
    );
  }

  // ========== Drawer ==========
  Drawer _buildDrawer(bool isRTL, BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryBlue, kSoftIndigo],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: _DrawerHeaderContent(),
          ),
          _drawerItem(
            icon: Icons.home,
            label: isRTL ? 'الرئيسية' : 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _drawerItem(
            icon: Icons.info_outline,
            label: isRTL ? 'من نحن' : 'About',
            onTap: () => Navigator.pop(context),
          ),
          _drawerItem(
            icon: Icons.contact_support_outlined,
            label: isRTL ? 'تواصل معنا' : 'Contact',
            onTap: () => Navigator.pop(context),
          ),
          _drawerItem(
            icon: Icons.info_outline,
            label: isRTL ? 'اعدادات السيرف' : 'settings server',
            onTap: () {
              Navigator.pop(context); // يقفل الـ Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ServerSettingsScreen()),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  ListTile _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryBlue),
      title: Text(
        label,
        style: const TextStyle(fontFamily: 'Cairo'),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
      onTap: onTap,
    );
  }
}

// ====== Body ======
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.watch<LanguageProvider>().isRTL;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _HeroSection(isRTL: isRTL),
          const SizedBox(height: 8),
          _ServicesSection(isRTL: isRTL),
          _AboutSection(isRTL: isRTL),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ========== Hero Section ==========
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isRTL});
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    final title = isRTL
        ? 'منصة طبية متكاملة لخدمتك'
        : 'Comprehensive Medical Platform for Your Service';
    final desc = isRTL
        ? 'نوفر لك أفضل الخدمات الطبية عبر الإنترنت: استشارات، مواعيد، ومتابعة صحية متكاملة.'
        : 'We provide the best online medical services: consultations, appointments, and comprehensive health tracking.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kPagePadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFEFF6FF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;

          final textChild = _FadeSlide(
            axis: Axis.horizontal,
            reverse: isRTL,
            child: Column(
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                // عنوان كبير: يسمح بالتفاف النص، ويقلم إذا زاد جداً
                Text(
                  title,
                  style: isWide ? kHeroTitleDesktop : kHeroTitleMobile,
                  textAlign: isWide ? TextAlign.start : TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  maxLines: isWide ? 2 : 3,
                ),
                const SizedBox(height: 16),
                // وصف: التفاف متعدد الأسطر بدون overflow
                Text(
                  desc,
                  style: kBody,
                  textAlign: isWide ? TextAlign.start : TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  maxLines: isWide ? 3 : 6,
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment:
                      isWide ? WrapAlignment.start : WrapAlignment.center,
                  children: const [
                    _ChipTag(label: '24/7'),
                    _ChipTag(label: 'Secure'),
                    _ChipTag(label: 'Pro Doctors'),
                  ],
                ),
              ],
            ),
          );

          final imageChild = const _ScaleFade(
            child: _HeroImage(
              url:
                  'https://storage.googleapis.com/a1aa/image/df4be675-eaf0-4bc7-83c8-e91e0d8275a7.jpg',
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: textChild),
                const SizedBox(width: 24),
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imageChild)),
              ],
            );
          }

          return Column(
            children: [
              textChild,
              const SizedBox(height: 22),
              ClipRRect(
                  borderRadius: BorderRadius.circular(16), child: imageChild),
            ],
          );
        },
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  const _ChipTag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style:
            const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        maxLines: 1,
      ),
      backgroundColor: kAccentTeal.withOpacity(.12),
      side: const BorderSide(color: kAccentTeal, width: .6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

// ========== Services Section ==========
class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.isRTL});
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('services'),
      color: Colors.white,
      padding: const EdgeInsets.all(kPagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(title: 'خدماتنا')
              .withLocalizedTitle(isRTL ? 'خدماتنا' : 'Our Services'),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 900
                  ? 3
                  : (constraints.maxWidth > 560 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cross,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _ServiceCard(
                    icon: Icons.support_agent,
                    title: isRTL ? 'استشارات طبية' : 'Medical Consultations',
                    description: isRTL
                        ? 'تواصل مع أطباء متخصصين للحصول على استشارات دقيقة وسريعة.'
                        : 'Connect with specialized doctors for accurate and quick consultations.',
                    color: kPrimaryBlue,
                    imageUrl:
                        'https://images.unsplash.com/photo-1584982827060-51236b63f7c7?q=80&w=1200&auto=format&fit=crop',
                  ),
                  _ServiceCard(
                    icon: Icons.calendar_month,
                    title: isRTL ? 'حجز مواعيد' : 'Appointments',
                    description: isRTL
                        ? 'احجز مواعيدك بسهولة وبدون عناء الانتظار.'
                        : 'Book appointments easily without waiting.',
                    color: kAccentTeal,
                    imageUrl:
                        'https://images.unsplash.com/photo-1512061942530-1f2a2fbfa3e1?q=80&w=1200&auto=format&fit=crop',
                  ),
                  _ServiceCard(
                    icon: Icons.favorite,
                    title: isRTL ? 'متابعة صحية' : 'Health Monitoring',
                    description: isRTL
                        ? 'متابعة لحالتك الصحية مع تقارير دورية ونصائح.'
                        : 'Track your health with periodic reports and tips.',
                    color: kSoftIndigo,
                    imageUrl:
                        'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?q=80&w=1200&auto=format&fit=crop',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: kAccentTeal,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        // امنع overflow في ترويسة القسم
        Expanded(
          child: Text(
            title,
            style: kSectionTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.imageUrl,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? imageUrl; // صورة اختيارية

  @override
  Widget build(BuildContext context) {
    return _ScaleFade(
      child: Material(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                // تمديد المساحة للنصوص ومنع overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      if (imageUrl != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: kBody,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========== About Section ==========
class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.isRTL});
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    const imageUrl =
        'https://storage.googleapis.com/a1aa/image/a82107de-bdc9-4434-330c-586faf33e3a8.jpg';

    final p1 = isRTL
        ? 'منصة طبية متكاملة تُسهّل الوصول إلى الرعاية الصحية عبر الإنترنت.'
        : 'A comprehensive platform that simplifies access to online healthcare.';
    final p2 = isRTL
        ? 'نلتزم بتجربة سلسة وآمنة مع محتوى موثوق وأطباء محترفين.'
        : 'We commit to a smooth, secure experience with trusted content and professional doctors.';

    return Container(
      key: const Key('about'),
      padding: const EdgeInsets.all(kPagePadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;
          final text = _FadeSlide(
            axis: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: isRTL ? 'من نحن' : 'About Us'),
                const SizedBox(height: 12),
                // صورة صغيرة معبّرة تحت العنوان
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 6,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1583912267554-c6f8b3a59b6a?q=80&w=1600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  p1,
                  style: kBody,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  maxLines: isWide ? 3 : 6,
                ),
                const SizedBox(height: 10),
                Text(
                  p2,
                  style: kBody,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  maxLines: isWide ? 3 : 6,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: const [
                    _InfoPill(text: 'ISO Privacy'),
                    _InfoPill(text: 'End-to-End'),
                    _InfoPill(text: 'Fast Support'),
                  ],
                ),
              ],
            ),
          );

          final image = const _ScaleFade(child: _HeroImage(url: imageUrl));

          if (isWide) {
            return Row(
              children: [
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16), child: image)),
                const SizedBox(width: 24),
                Expanded(child: text),
              ],
            );
          }
          return Column(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
              const SizedBox(height: 16),
              text,
            ],
          );
        },
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kSoftIndigo.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kSoftIndigo, width: .6),
      ),
      child: Text(
        text,
        style:
            const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}

// ====== Widgets مساعدة للحركات ======
class _FadeSlide extends StatelessWidget {
  const _FadeSlide({
    required this.child,
    this.axis = Axis.horizontal,
    this.reverse = false,
    this.duration = const Duration(milliseconds: 650),
  });
  final Widget child;
  final Axis axis;
  final bool reverse; // عكس اتجاه الانزلاق
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, c) {
        final dx =
            axis == Axis.horizontal ? (reverse ? (1 - t) : -(1 - t)) * 24 : 0.0;
        final dy = axis == Axis.vertical ? (1 - t) * 16 : 0.0;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

class _ScaleFade extends StatelessWidget {
  const _ScaleFade({
    required this.child,
    this.duration = const Duration(milliseconds: 700),
  });
  final Widget child;
  final Duration duration;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .96, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, t, c) {
        final opacity = ((t - 0.92) / (1 - 0.92)).clamp(0.0, 1.0);
        return Opacity(opacity: opacity, child: c);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .96, end: 1),
        duration: duration,
        curve: Curves.easeOutBack,
        builder: (context, t, c) => Transform.scale(scale: t, child: c),
        child: child,
      ),
    );
  }
}

// ======= Widgets مساعدة صغيرة =======
class _DrawerHeaderContent extends StatelessWidget {
  const _DrawerHeaderContent();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.watch<LanguageProvider>().isRTL;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              const Icon(Icons.medical_services, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 10),
        Text(
          isRTL ? 'المنصة الطبية' : 'Medical Platform',
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(url, fit: BoxFit.cover);
  }
}

extension _LocalizedHeader on _SectionHeader {
  _SectionHeader withLocalizedTitle(String newTitle) =>
      _SectionHeader(title: newTitle);
}
