import 'package:bookrec/components/book_grid.dart';
import 'package:bookrec/components/star.dart';
import 'package:bookrec/pages/FeaturedPage.dart';
import 'package:bookrec/pages/HomePage.dart';
import 'package:bookrec/pages/book_and_similar.dart';
import 'package:bookrec/pages/book_search.dart';
import 'package:bookrec/pages/chatapp.dart';
import 'package:bookrec/pages/dashboard.dart';
import 'package:bookrec/pages/dashboard_home.dart';
import 'package:bookrec/pages/dashboard_shelf.dart';
import 'package:bookrec/pages/dashboard_discussion.dart';
import 'package:bookrec/pages/dashboard_trending.dart';
import 'package:bookrec/pages/forgotPassword.dart';
import 'package:bookrec/pages/isLoading.dart';
import 'package:bookrec/pages/likeBook.dart';
import 'package:bookrec/pages/resetPassword.dart';
import 'package:bookrec/pages/sign.dart';
import 'package:bookrec/pages/signup.dart';
import 'package:bookrec/pages/verifyEmail.dart';
import 'package:bookrec/pages/view_discussion.dart';
import 'package:bookrec/pages/write_review.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/provider/bookprovider.dart';
import 'package:bookrec/provider/catprovider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  print('BASE URL: ${dotenv.env['baseUrl']}');

  runApp(const MainApp());
}

final GoRouter _router = GoRouter(
  routes: [
    // These routes are NOT wrapped in Homepage
    GoRoute(
      path: '/reset-password/:token',
      builder: (context, state) {
        final token = state.pathParameters['token']!;
        return ResetPasswordPage(token: token);
      },
    ),
    GoRoute(
      path: '/verify-email/:token',
      builder: (context, state) {
        final token = state.pathParameters['token']!;
        return Isloading(token: token);
      },
    ),
    GoRoute(
      path: '/ebook',
      builder: (context, state) {
        return Chatapp();
      },
    ),
    // ShellRoute wraps all dashboard/homepage routes
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return Homepage(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => FeaturedPage()),

        GoRoute(
          path: '/like',
          builder: (context, state) => BookSelectionPage(),
        ),
        GoRoute(
          path: '/view/:id',
          builder: (context, state) {
            final forumId = state.pathParameters['id'];
            return ForumDetailPage(forumId: forumId!);
          },
        ),

        GoRoute(
          path: '/writereview/:id/:title',

          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final title = state.pathParameters['title']!;
            //final decodedTitle = Uri.decodeComponent(title);
            print('Book ID: $id, Title: $title');
            return WriteReview(bookId: id, title: title);
          },
        ),

        GoRoute(
          path: '/book/:id/:title',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final title = state.pathParameters['title']!;
            //final decodedTitle = Uri.decodeComponent(title);
            print('Book ID: $id, Title: $title');

            return BookAndSimilar(bookId: id, title: title);
          },
        ),
        GoRoute(
          path: '/search/:prompt',
          builder: (context, state) {
            //final id = state.pathParameters['id']!;
            final prompt = state.pathParameters['prompt']!;
            //final decodedTitle = Uri.decodeComponent(title);
            //print('Book ID: $id, Title: $title');

            return SearchResultsPage(prompt: prompt);
          },
        ),

        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return DashboardPage(child: child); // This is your shared layout
          },
          routes: [
            GoRoute(
              path: '/dashboard/home',
              builder: (context, state) => DashboardHome(),
              routes: [
                GoRoute(
                  path: '/book/:prompt',
                  builder: (context, state) {
                    //final id = state.pathParameters['id']!;
                    final prompt = state.pathParameters['prompt']!;
                    //final decodedTitle = Uri.decodeComponent(title);
                    //print('Book ID: $id, Title: $title');

                    return BookSearchResultsPage(prompt: prompt);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/dashboard/shelf',
              builder: (context, state) => const DashboardShelf(),
            ),

            GoRoute(
              path: '/dashboard/discussion',
              builder: (context, state) => DiscussionPage(),
              routes: [],
            ),
            GoRoute(
              path: '/dashboard/trending',
              builder: (context, state) => const DashboardTrending(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SignInPage(),
      routes: [
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignUpPage(),
          routes: [
            GoRoute(
              path: 'verify',
              builder: (context, state) => EmailVerificationPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CatProvider()),
        ChangeNotifierProvider(create: (_) => Bookprovider()),
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate, // Required for Quill
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('es'), // Spanish
          Locale('fr'), // French
          Locale('de'), // German
          Locale('zh'), // Chinese
          // Add more locales as needed
        ],

        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
//commenting for vercel deployment
