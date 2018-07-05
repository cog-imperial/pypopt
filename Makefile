test:
	python setup.py test

publish:
	pip install twine
	python setup.py sdist
	twine upload dist/*
	rm -rf build dist .egg suspect.egg-info

clean:
	rm -rf build dist .egg pypopt.egg-info htmlcov
