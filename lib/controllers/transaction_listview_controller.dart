import 'package:meu_financeiro/models/transaction_model.dart';
import 'package:meu_financeiro/repositories/transaction_repository.dart';
import 'package:flutter/foundation.dart';

import '../common/widgets/transaction_listview/transaction_listview_state.dart';

class TransactionListViewController extends ChangeNotifier {
  TransactionListViewController({
    required this.transactionRepository,
  });

  final TransactionRepository transactionRepository;
  TransactionListViewState _state = TransactionListViewStateInitial();

  TransactionListViewState get state => _state;

  void _changeState(TransactionListViewState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    _changeState(TransactionListViewStateLoading());
    final result =
        await transactionRepository.deleteTransaction(transaction.id!);

    result.fold(
      (error) => _changeState(TransactionListViewStateError(error.message)),
      (data) => _changeState(TransactionListViewStateSuccess()),
    );
  }
}
