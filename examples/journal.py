import sys
import io
from pypopt import (
    IpoptApplication,
    PythonJournal,
    EJournalLevel,
    EJournalCategory,
)


if __name__ == '__main__':
    app = IpoptApplication()

    print(app.options().get_string_value('output_file'))
    app.options().set_string_value('output_file', 'test.out')
    print(app.options().get_string_value('output_file'))
    print('---' * 10)
    f = io.StringIO()
    j = PythonJournal(EJournalLevel.J_NONE, f)

    jnlst = app.journalist()
    jnlst.add_journal(j)
