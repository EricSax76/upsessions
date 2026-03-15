import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/public_venues_cubit.dart';
import '../../cubits/public_venues_state.dart';
import '../widgets/public_venues/public_venues_empty_state.dart';
import '../widgets/public_venues/public_venues_error_state.dart';
import '../widgets/public_venues/public_venues_filters.dart';
import '../widgets/public_venues/public_venues_header.dart';
import '../widgets/public_venues/public_venues_list.dart';

class PublicVenuesPage extends StatefulWidget {
  const PublicVenuesPage({super.key});

  @override
  State<PublicVenuesPage> createState() => _PublicVenuesPageState();
}

class _PublicVenuesPageState extends State<PublicVenuesPage> {
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PublicVenuesCubit>().loadVenues();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<PublicVenuesCubit>().applyFilters(
      city: _cityController.text,
      province: _provinceController.text,
    );
  }

  void _retryLoad() {
    context.read<PublicVenuesCubit>().loadVenues(refresh: true);
  }

  void _loadMore() {
    context.read<PublicVenuesCubit>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicVenuesCubit, PublicVenuesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PublicVenuesHeader(),
            PublicVenuesFilters(
              cityController: _cityController,
              provinceController: _provinceController,
              isLoading: state.isLoading,
              onApply: _applyFilters,
            ),
            Expanded(child: _buildBody(state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(PublicVenuesState state) {
    if (state.isLoading && state.venues.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.venues.isEmpty) {
      return PublicVenuesErrorState(
        message: state.errorMessage!,
        onRetry: _retryLoad,
      );
    }

    if (state.venues.isEmpty) {
      return const PublicVenuesEmptyState();
    }

    return PublicVenuesList(
      venues: state.venues,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      onLoadMore: _loadMore,
    );
  }
}
