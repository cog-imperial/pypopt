import pytest
import io
from pypopt import PythonJournal, EJournalLevel, EJournalCategory
from tests.conftest import app


def test_can_add_journal(app):
    sio = io.StringIO()
    journal = PythonJournal(EJournalLevel.J_NONE, sio)
    assert app.journalist().add_journal(journal)
    assert not app.journalist().add_journal(journal)


def test_can_get_journal(app):
    sio = io.StringIO()
    journal = PythonJournal(EJournalLevel.J_NONE, sio)
    assert app.journalist().add_journal(journal)
    assert app.journalist().get_journal('PythonJournal')


def test_python_journal():
    sio = io.StringIO()
    journal = PythonJournal(EJournalLevel.J_NONE, sio)
    assert journal.name() == b'PythonJournal'
    journal.print_(EJournalCategory.J_DBG, EJournalLevel.J_NONE, b'TEST BYTES')
    assert sio.getvalue() == 'TEST BYTES'


def test_python_journal_inside_journalist(app):
    sio = io.StringIO()
    journal = PythonJournal(EJournalLevel.J_NONE, sio)
    assert app.journalist().add_journal(journal)

    app.journalist().printf(
        EJournalCategory.J_DBG, EJournalLevel.J_NONE,
        'TEST {} PLEASE IGNORE {}{}', 'POST', 0, 1
    )
    app.journalist().flush_buffer()
    assert sio.getvalue() == 'TEST POST PLEASE IGNORE 01'
