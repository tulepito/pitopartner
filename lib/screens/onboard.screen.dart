import 'package:flutter/material.dart';
import 'package:pitopartner/main.dart';
import 'package:pitopartner/services/shared_preferences.service.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    this.isActive = false,
    super.key,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary : Colors.black38,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }
}

class OnBoardContent extends StatelessWidget {
  const OnBoardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          image,
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.bottomCenter,
          fit: BoxFit.cover,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, textAlign: TextAlign.left, style: TextStyles.h3),
              Text(description, style: TextStyles.bodyText2),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class OnBoard {
  final String image, title, description;

  OnBoard({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnBoard> demoData = [
  OnBoard(
    image: "assets/images/onboarding/screen_1.png",
    title: "Chào mừng đến với PITO",
    description:
        "PITO là nền tảng đặt dịch vụ ăn uống cho doanh nghiệp đầu tiên tại Việt Nam",
  ),
  OnBoard(
    image: "assets/images/onboarding/screen_2.png",
    title: "Nhập thông tin, tìm nhà hàng",
    description:
        "Nhập thời gian, địa điểm, số lượng người cho nhóm của bạn và chúng tôi sẽ đề xuất các nhà hàng phù hợp",
  ),
  OnBoard(
    image: "assets/images/onboarding/screen_3.png",
    title: "Chọn món, thanh toán",
    description:
        "Chọn các món và tuỳ chỉnh theo số lượng, nhu cầu của bạn. Lựa chọn hình thức thanh toán phù hợp với bạn",
  ),
  OnBoard(
    image: "assets/images/onboarding/screen_4.png",
    title: "Nhận đồ ăn và thưởng thức",
    description:
        "Nhận đồ ăn được giao từ nhà hàng và thưởng thức cùng nhóm của bạn",
  ),
];

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void viewApp(BuildContext context) {
    SharedPreferencesService.saveOnboardingStatus(true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AppWithNavigationBar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Text buttonText = Text(
      _pageIndex == 0
          ? 'Tôi là người mới'
          : _pageIndex == demoData.length - 1
              ? "Đăng nhập"
              : "Tiếp tục",
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    );

    Widget secondaryButton = _pageIndex == 0
        ? InkWell(
            onTap: () {
              viewApp(context);
            },
            child: Container(
              height: 48,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(32)),
              ),
              child: const Center(
                  child: Text(
                'Đã có tài khoản, đăng nhập',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              )),
            ),
          )
        : const SizedBox();

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemCount: demoData.length,
                  controller: _pageController,
                  itemBuilder: (context, index) => OnBoardContent(
                    title: demoData[index].title,
                    description: demoData[index].description,
                    image: demoData[index].image,
                  ),
                ),
              ),
              // indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      demoData.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            )
                          },
                          child: DotIndicator(
                            isActive: index == _pageIndex,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // buttons
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: _pageIndex == 0 ? 0 : 48,
                    ),
                    InkWell(
                      onTap: () {
                        if (_pageIndex == demoData.length - 1) {
                          viewApp(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      child: Container(
                        height: 48,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                        ),
                        child: Center(child: buttonText),
                      ),
                    ),
                    secondaryButton,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
