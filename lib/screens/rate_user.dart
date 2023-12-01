import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateUserPageArguments {
  final String id;

  RateUserPageArguments(this.id);
}

class RateUserPage extends StatefulWidget {
  final RateUserPageArguments arguments;
  const RateUserPage({Key? key, required this.arguments}) : super(key: key);

  @override
  State<RateUserPage> createState() => _RateUserPageState();
}

class _RateUserPageState extends State<RateUserPage> {
  final _commentController = TextEditingController();

  Future<Map<String, dynamic>> fetchUserDetails(String userID) async {
    final response = await dio.get('$apiURL/get_user_by_id/$userID');

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  void addRating(String nickname, String comment, double rating) async {
    final response = await dio.post('$apiURL/add_rating', data: {
      'sellerName': nickname,
      'comment': comment,
      'rating': rating,
    });

    if (context.mounted) {
      if (response.statusCode == 200 && response.data['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added review', textAlign: TextAlign.center),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add review', textAlign: TextAlign.center),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double titleSize = screenSize.width > 600 ? 24 : 20;
    return FutureBuilder(
      future: fetchUserDetails(widget.arguments.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text('Rate User',
                    style: TextStyle(color: Colors.black, fontSize: titleSize)),
                centerTitle: true,
                elevation: 1,
              ),
              body: const Center(
                  child: Text('Error: Unable to load user details')));
        } else {
          var user = snapshot.data?['user'];
          var nickname = user['nickname'];
          var userName = (user['fullName'] == null || user['fullName'] == '')
              ? user['nickname']
              : user['fullName'];
          var userProfilePicUrl = user['photoUrl'] ?? '';
          var avgRating = user['rating_avg'] ?? 0;
          avgRating = avgRating == 0 ? 2.5 : avgRating;

          var ratings = user['ratings'] ?? [];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('Rate $userName',
                  style: TextStyle(color: Colors.black, fontSize: titleSize)),
              centerTitle: true,
              elevation: 1,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRatingForm(
                      userProfilePicUrl, userName, nickname, avgRating),
                  _buildRatingsList(ratings),
                  // Your other UI components
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildRatingForm(String userProfilePicUrl, String userName,
      String nickname, double rating) {
    Size screenSize = MediaQuery.of(context).size;
    double padding = screenSize.width > 600 ? 20 : 12;
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userProfilePicUrl),
                  radius: 40,
                ),
                const SizedBox(height: 8),
                Text(userName),
              ],
            ),
          ),

          // Rating and Comment Section
          Expanded(
            flex: 2,
            child: Column(
              children: [
                TextFormField(
                  controller: _commentController,
                  decoration:
                      const InputDecoration(hintText: 'Leave a comment'),
                ),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (r) {
                    rating = r;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    addRating(nickname, _commentController.text, rating);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList(List<dynamic> ratings) {
    return ListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // To disable scrolling within ListView
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        var rating = ratings[index];
        var fullStars = rating['rating'].floor();
        var halfStar = rating['rating'] - fullStars >= 0.5 ? 1 : 0;
        var emptyStars = 5 - fullStars - halfStar;

        return ListTile(
          leading: CircleAvatar(
            // Displaying initials if no image is available
            child: Text(rating['user'][0]),
          ),
          title: Text(rating['user']),
          subtitle: Text(rating['comment']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(fullStars,
                  (_) => const Icon(Icons.star, color: Colors.amber)),
              if (halfStar == 1)
                const Icon(Icons.star_half, color: Colors.amber),
              ...List.generate(emptyStars.toInt(),
                  (_) => const Icon(Icons.star_border, color: Colors.amber)),
            ],
          ),
        );
      },
    );
  }
}
